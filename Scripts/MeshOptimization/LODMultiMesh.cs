using Godot;
using System;
using System.Collections;
using Lod;

public class LODMultiMesh : MultiMeshInstance
{
    public LODHandler lODHandler;
    public Mesh mesh;
    public float triggerDistance;
    public ArrayList meshes = new ArrayList();

    public ArrayList newMeshes = new ArrayList();

    public ArrayList oldMeshes = new ArrayList();

    public bool busy = false;

    public LODMesh popMesh(int i) {
        LODMesh mesh = (LODMesh) meshes[i];
        meshes.Remove(mesh);
        return mesh;
    }

    public void removeMesh(LODMesh mesh) {
        oldMeshes.Add(mesh);
        lODHandler.SetProcess(true);
    }

    public void addMeshes(ArrayList meshes) {
        this.meshes.AddRange(meshes);

        foreach (LODMesh m in meshes)
        {
            m.currentMultimesh = this;
        }
    }

    public void validateMeshes() {
        ArrayList invalidMeshes = new ArrayList();
        foreach (Spatial mesh in meshes)
        {
            if(!IsInstanceValid(mesh)) invalidMeshes.Add(mesh);
        }
        foreach (var mesh in invalidMeshes)
        {
            lODHandler.CallDeferred("lowerMeshCount");
            meshes.Remove(mesh);
        }
    }

    private void notifyNewMeshes() {
        foreach (LODMesh mesh in newMeshes)
        {
            if(IsInstanceValid(mesh)) {
                mesh.CallDeferred("integrateMesh");
            }
        }

        newMeshes.Clear();
    }

    public void removeOldMeshes() {
        foreach (LODMesh mesh in oldMeshes)
        {
            meshes.Remove(mesh);
        }

        oldMeshes.Clear();
    }

    public void updateMesh() {
        if(mesh == null) {
            Visible = false;
            return;
        }


        CallDeferred("notifyNewMeshes");

        ArrayList meshesToDraw = new ArrayList();
        foreach (Spatial mesh in meshes)
        {
            if(mesh.IsVisibleInTree() && mesh.IsInsideTree()) meshesToDraw.Add(mesh);
        }

        busy = true;
        MultiMesh mm = new MultiMesh();
        mm.TransformFormat = MultiMesh.TransformFormatEnum.Transform3d;
        mm.ColorFormat = MultiMesh.ColorFormatEnum.None;
        mm.CustomDataFormat = MultiMesh.CustomDataFormatEnum.None;
        mm.Mesh = mesh;

        mm.InstanceCount = meshesToDraw.Count;

        
        for (int i = 0; i < mm.InstanceCount; i++)
        {
            Spatial instance = (Spatial) meshesToDraw[i];
            mm.SetInstanceTransform(i,instance.GlobalTransform);
        }

        

        CallDeferred("setMultiMesh",mm);
        busy = false;
        // GD.Print("MESH UPDATED");
    }

    public void setMultiMesh(MultiMesh mesh) {
        Multimesh = mesh;
    }
}
