using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FurGrass : MonoBehaviour {
    public GameObject source;
    public int count = 50;
    public float height = 1.0f;

    Matrix4x4[] matrices;

    [ExecuteInEditMode]
    void Start () {
        matrices = new Matrix4x4[count];

        for (int i = 0; i < count; i++)
        {
            var position = this.transform.position;
            position += new Vector3(0.0f, (i+1)*height/count, 0.0f);
            matrices[i] = Matrix4x4.TRS(position, this.transform.rotation, this.transform.localScale);
        }

        source.GetComponent<Renderer>().sharedMaterial.SetInt("count", count);
    }
	
	// Update is called once per frame
	void Update () {
        Graphics.DrawMeshInstanced(source.GetComponent<MeshFilter>().sharedMesh, 0, source.GetComponent<Renderer>().sharedMaterial, matrices, count);
    }
}
