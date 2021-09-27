using Godot;
using System;

namespace Lod
{
    public class LODMesh : MeshInstance
    {
        [Export] String meshName = "mesh";

        [Export] bool dynamic = false;
        // [Export] bool hideSelf = true;
        [Export] Mesh[] LODMeshes = new Mesh[0];
        [Export] float[] triggerDistances = new float[0];

        public LODMultiMesh currentMultimesh;

        LODHandler LODHandler;

        public float distanceToPlayer;

        public override void _Ready()
        {
            
        }

        public void drawMesh()
        {
            setLODHandler();
            LODHandler.addMesh(this);
        }

        public void integrateMesh() {
            Mesh = null;
            MaterialOverride = null;
        }

        void setLODHandler()
        {
            if (LODHandler == null)
            {
                Node root = GetNode("/root");
                if (root.HasNode("LODHandler " + meshName))
                {
                    LODHandler = root.GetNode<LODHandler>("LODHandler " + meshName);
                }
                else
                {
                    LODHandler = createLODHandler();
                }
            }
        }

        LODHandler createLODHandler()
        {
            Node root = GetNode("/root");

            LODHandler LODHandler = (LODHandler)((PackedScene)root.GetNode("GlobalPackedScenes").Get("LODHandler")).Instance();
            root.AddChild(LODHandler);
            LODHandler.dynamic = dynamic;
            LODHandler.overrideMaterial = MaterialOverride;
            LODHandler.shadowMode = CastShadow;
            LODHandler.prepare(LODMeshes, triggerDistances);
            LODHandler.Name = "LODHandler " + meshName;
            return LODHandler;
        }

        // public override void _ExitTree()
        // {
        //     removeMesh();
        //     base._ExitTree();
        // }
        // public override void _EnterTree()
        // {
        //     if(currentMultimesh == null) {
        //         CallDeferred("drawMesh");
        //         integrateMesh();
        //     }
        // }

        // public override void _ExitTree()
        // {
        //     if(currentMultimesh != null) {
        //         currentMultimesh.CallDeferred("removeMesh",this);
        //         currentMultimesh = null;
        //     }
        // }
    }
}
