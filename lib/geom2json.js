// https://github.com/mrdoob/three.js/issues/1225

module.exports = function geom2json(geometry) {
  var i,
  json = {
    metadata: {
      formatVersion: 4
    },
    scale: 1.000000,
    materials: [],
    vertices: [],
    morphTargets: [],
    morphColors: [],
    normals: [],
    colors: [],
    uvs: [[]],
    faces: []
  };

  for (i = 0; i < geometry.vertices.length; i++) {
    json.vertices.push(geometry.vertices[i].x);
    json.vertices.push(geometry.vertices[i].y);
    json.vertices.push(geometry.vertices[i].z);
  }

  for (i = 0; i < geometry.faces.length; i++) {
    if (geometry.faces[i].d) {
      json.faces.push(1);
    } else {
      json.faces.push(0);
    }

    json.faces.push(geometry.faces[i].a);
    json.faces.push(geometry.faces[i].b);
    json.faces.push(geometry.faces[i].c);

    if (geometry.faces[i].d) {
      json.faces.push(geometry.faces[i].d);
    }

    json.normals.push(geometry.faces[i].normal.x);
    json.normals.push(geometry.faces[i].normal.y);
    json.normals.push(geometry.faces[i].normal.z);
  }

  return json;
}
