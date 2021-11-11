using Godot;
using System;
using System.Collections;
using Lod;

public class LODHandler : Spatial
{
    PackedScene LODMeshScene;
    LODMultiMesh[] LODLayers;

    ArrayList newMeshes = new ArrayList();
    Godot.Thread thread;
    Godot.Semaphore semaphore = new Godot.Semaphore();

    float timer = 0.5f;

    bool updateWithLOD = false;
    bool threadUpdateWithLOD = false;

    Node GlobalVariables;
    Vector3 playerTranslation = new Vector3(0,0,0);
    Vector3 threadTranslation = new Vector3(0,0,0);

    bool threadActive = false;

    public bool dynamic = false;
    
    public Material overrideMaterial;
    public int meshCount = 0;

    public MeshInstance.ShadowCastingSetting shadowMode;

    public void prepare(Mesh[] meshes, float[] triggerDistances)
    {
        GlobalVariables = GetNode("/root/GlobalVariables");
        GlobalVariables.Call("addObserver",this);
        playerTranslation = (Vector3) GlobalVariables.Get("playerTranslation");

        LODMeshScene = (PackedScene)GetNode("/root/GlobalPackedScenes").Get("LODMultiMesh");
        LODLayers = new LODMultiMesh[meshes.Length];

        for (int i = 0; i < LODLayers.Length; i++)
        {
            LODLayers[i] = createLodMultiMesh(meshes[i], triggerDistances[i]);
        }

        if(!dynamic) {
            thread = new Godot.Thread();
            thread.Start(this,"threadFunction","data", Godot.Thread.Priority.Low);
        }
    }

    public void threadFunction(String data)
    {
        while (!queuedForDestruction)
        {
            semaphore.Wait();
            // GD.Print("LOD START");
            updateMesh(threadUpdateWithLOD);
            CallDeferred("finishThread");
            // GD.Print("LOD END");
        }
    }

    private void finishThread() {
        threadActive = false;
    }

    public override void _Process(float delta)
    {
        if(dynamic) {
            integrateNewMeshes();
            removeOldMeshes();
            updateMesh(updateWithLOD);
            updateWithLOD = false;
        } else {
            timer += delta;
            if (threadActive == false && timer > 1f)
            {
                startThread();
            }
        }
    }

    public void startThread() {
        if(queuedForDestruction) return;
        timer = 0f;
        removeOldMeshes();
        integrateNewMeshes();
        if (checkMeshCount()) return;
        threadActive = true;
        threadUpdateWithLOD = updateWithLOD;
        updateWithLOD = false;
        SetProcess(false);
        semaphore.Post();
    }

    private bool checkMeshCount() {
        int meshCount = 0;
        foreach (LODMultiMesh mesh in LODLayers)
        {
            meshCount += mesh.meshes.Count;
        }

        if (meshCount == 0) {
            GlobalVariables.Call("removeObserver",this);
            QueueFree();
            return true;
        } else {
            return false;
        }
    }

    private void integrateNewMeshes() {
        Vector3 playerTranslation = (Vector3)GetNode("/root/GlobalVariables").Get("playerTranslation");
        foreach (LODMesh mesh in newMeshes)
        {
            if (!IsInstanceValid(mesh)) return;
            mesh.distanceToPlayer = 0;
            mesh.currentMultimesh = getCorrectMultiMesh(mesh);
            mesh.currentMultimesh.meshes.Add(mesh);
            mesh.currentMultimesh.newMeshes.Add(mesh);
            raiseMeshCount();
        }
        newMeshes = new ArrayList();
    }

    private void removeOldMeshes() {
        foreach (LODMultiMesh layer in LODLayers)
        {
            layer.removeOldMeshes();
        }
    }

    private LODMultiMesh getCorrectMultiMesh(LODMesh mesh) {
        for (int i = 0; i < LODLayers.Length; i++)
        {
            LODMultiMesh currentLOD = LODLayers[i];
            LODMultiMesh nextLOD = GetMultiMesh(i + 1);
            if(nextLOD != null) {
                if(mesh.distanceToPlayer >= currentLOD.triggerDistance && mesh.distanceToPlayer < nextLOD.triggerDistance) {
                    return currentLOD;
                }
            } else {
                return currentLOD;
            }
        }
        return null;
    }

    public void playerMoved()
    {
        playerTranslation = (Vector3) GlobalVariables.Get("playerTranslation");
        updateWithLOD = true;
        SetProcess(true);
    }

    public void addMesh(LODMesh mesh)
    {
        newMeshes.Add(mesh);
        SetProcess(true);
    }

    public void updateMesh(bool lod = false)
    {
        foreach (LODMultiMesh multiMesh in LODLayers)
        {
            multiMesh.validateMeshes();
        }

        if (lod) runLODCalculation();

        for (int i = 0; i < LODLayers.Length; i++)
        {
            LODMultiMesh mesh = LODLayers[i];
            mesh.CallDeferred("updateMesh");
        }
    }

    bool queuedForDestruction = false;
    public void lowerMeshCount() {
        meshCount -= 1;
        if(meshCount <= 0 && !queuedForDestruction) {
            queuedForDestruction = true;
            CallDeferred("disableThread");
            CallDeferred("deleteLODHandler");
        }
    }

    bool threadRerun = true;
    public void disableThread() {
        threadRerun = false;
        semaphore.Post();
    }

    public void raiseMeshCount() {
        meshCount += 1;
    }

    void runLODCalculation()
    {
        runDistanceCalculations();

        for (int i = 0; i < LODLayers.Length; i++)
        {
            LODMultiMesh currentLOD = LODLayers[i];
            if(!currentLOD.busy) {
                LODMultiMesh previousLOD = GetMultiMesh(i - 1);
                LODMultiMesh nextLOD = GetMultiMesh(i + 1);

                if (previousLOD != null) if(!previousLOD.busy) previousLOD.addMeshes(extractMeshesFromLayer(currentLOD, currentLOD.triggerDistance, false));
                if (nextLOD != null) if(!nextLOD.busy) nextLOD.addMeshes(extractMeshesFromLayer(currentLOD, nextLOD.triggerDistance, true));
            }
        }
    }

    ArrayList extractMeshesFromLayer(LODMultiMesh layer, float threshold, bool next)
    {
        ArrayList extractedMeshes = new ArrayList();

        for (int i = layer.meshes.Count - 1; i >= 0; i--)
        {
            LODMesh mesh = (LODMesh)layer.meshes[i];

            if (next)
            {
                if (mesh.distanceToPlayer >= threshold) extractedMeshes.Add(layer.popMesh(i));
            }
            else
            {
                if (mesh.distanceToPlayer < threshold) extractedMeshes.Add(layer.popMesh(i));
            }
        }

        return extractedMeshes;
    }

    void runDistanceCalculations()
    {
        Vector3 playerTranslation = (Vector3)GetNode("/root/GlobalVariables").Get("playerTranslation");

        for (int i = 0; i < LODLayers.Length; i++)
        {
            LODMultiMesh layer = LODLayers[i];

            for (int m = 0; m < layer.meshes.Count; m++)
            {
                LODMesh mesh = (LODMesh)layer.meshes[m];
                mesh.distanceToPlayer = distanceBetweenVectors(mesh.GlobalTransform.origin,playerTranslation);
            }
        }
    }

    LODMultiMesh createLodMultiMesh(Mesh mesh, float triggerDistance)
    {
        LODMultiMesh LODMultiMesh = (LODMultiMesh)LODMeshScene.Instance();
        LODMultiMesh.mesh = mesh;
        LODMultiMesh.triggerDistance = triggerDistance;
        LODMultiMesh.lODHandler = this;
        LODMultiMesh.MaterialOverride = overrideMaterial;
        LODMultiMesh.CastShadow = shadowMode;
        AddChild(LODMultiMesh);
        return LODMultiMesh;
    }

    LODMultiMesh GetMultiMesh(int i)
    {
        if (i >= LODLayers.Length || i < 0) return null;
        return LODLayers[i];
    }

    private void deleteLODHandler() {
        if(thread != null) thread.WaitToFinish();
        GlobalVariables.Call("removeObserver",this);
        QueueFree();
    }

    float distanceBetweenVectors(Vector3 a, Vector3 b)
    {
        return (diff(a.x, b.x) + diff(a.y, b.y) + diff(a.z, b.z));
    }

    float diff(float a, float b)
    {
        if (a < b)
        {
            return b - a;
        }
        else
        {
            return a - b;
        }
    }
}
