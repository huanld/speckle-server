# 🚀 Hướng dẫn sử dụng IFC Libraries

Tài liệu này hướng dẫn cách sử dụng các thư viện IFC trong Speckle Server.

---

## Mục lục

1. [Cài đặt môi trường](#cài-đặt-môi-trường)
2. [Sử dụng fileimport-service (web-ifc)](#sử-dụng-fileimport-service-web-ifc)
3. [Sử dụng ifc-import-service (ifcopenshell)](#sử-dụng-ifc-import-service-ifcopenshell)
4. [Best Practices](#best-practices)
5. [Xử lý lỗi thường gặp](#xử-lý-lỗi-thường-gặp)

---

## Cài đặt môi trường

### Prerequisites

```bash
# Node.js (cho fileimport-service)
node >= 18.0.0

# Python (cho ifc-import-service)
python >= 3.10

# Yarn (package manager)
yarn >= 4.0.0
```

### Cài đặt fileimport-service

```bash
cd packages/fileimport-service
yarn install
```

### Cài đặt ifc-import-service

```bash
cd packages/ifc-import-service
pip install -r requirements.txt

# Hoặc với poetry/uv
uv sync
```

---

## Sử dụng fileimport-service (web-ifc)

### Vị trí code

```
packages/fileimport-service/src/ifc/
├── parser.js      # Main IFC parser
├── converter.js   # Convert to Speckle objects
└── utils.js       # Helper functions
```

### Workflow cơ bản

```javascript
import WebIFC from 'web-ifc/web-ifc-api-node.js'
import fs from 'fs'

// 1. Khởi tạo API
const ifcApi = new WebIFC.IfcAPI()
await ifcApi.Init()

// 2. Đọc file
const buffer = fs.readFileSync('model.ifc')
const modelID = ifcApi.OpenModel(new Uint8Array(buffer), {
  COORDINATE_TO_ORIGIN: true,
  USE_FAST_BOOLS: true
})

// 3. Lấy elements
const allTypes = [
  WebIFC.IFCWALL,
  WebIFC.IFCSLAB,
  WebIFC.IFCDOOR,
  WebIFC.IFCWINDOW,
  WebIFC.IFCCOLUMN,
  WebIFC.IFCBEAM
]

for (const type of allTypes) {
  const ids = ifcApi.GetLineIDsWithType(modelID, type)
  for (let i = 0; i < ids.size(); i++) {
    const id = ids.get(i)
    const element = ifcApi.GetLine(modelID, id)
    
    // Process element...
    console.log(element)
  }
}

// 4. Lấy geometry
ifcApi.StreamAllMeshes(modelID, (mesh) => {
  const placedGeometry = mesh.geometries
  for (let i = 0; i < placedGeometry.size(); i++) {
    const geometry = placedGeometry.get(i)
    const vertices = ifcApi.GetVertexArray(
      geometry.geometryExpressID,
      geometry.flatTransformation
    )
    const indices = ifcApi.GetIndexArray(geometry.geometryExpressID)
    
    // Convert to Speckle mesh...
  }
})

// 5. Cleanup
ifcApi.CloseModel(modelID)
```

### Chạy service

```bash
cd packages/fileimport-service
yarn dev
```

---

## Sử dụng ifc-import-service (ifcopenshell)

### Vị trí code

```
packages/ifc-import-service/src/ifc_importer/
├── __init__.py
├── process_job.py    # Main job processor
├── converter.py      # IFC to Speckle conversion
└── utils.py          # Helper functions
```

### Workflow cơ bản

```python
from speckleifc.main import open_and_convert_file
from specklepy.api.client import SpeckleClient
from specklepy.api.credentials import get_default_account
from specklepy.transports.server import ServerTransport
from specklepy.api.operations import send

# 1. Convert IFC to Speckle Base object
base_object = open_and_convert_file(
    ifc_path='model.ifc'
)

# 2. Setup Speckle client
client = SpeckleClient(host='https://your-speckle-server.com')
account = get_default_account()
client.authenticate_with_token(account.token)

# 3. Create transport
transport = ServerTransport(
    stream_id='your-stream-id',
    client=client
)

# 4. Send to Speckle
object_id = send(base=base_object, transports=[transport])
print(f"Sent object: {object_id}")
```

### Sử dụng ifcopenshell trực tiếp

```python
import ifcopenshell
import ifcopenshell.geom
import ifcopenshell.util.element

# Mở file
model = ifcopenshell.open('model.ifc')

# Lấy project info
project = model.by_type('IfcProject')[0]
print(f"Project: {project.Name}")
print(f"Schema: {model.schema}")

# Lấy spatial structure
def get_spatial_structure(element, level=0):
    indent = "  " * level
    print(f"{indent}{element.is_a()}: {element.Name or 'N/A'}")
    
    # Aggregates
    for rel in getattr(element, 'IsDecomposedBy', []):
        for child in rel.RelatedObjects:
            get_spatial_structure(child, level + 1)
    
    # Contained elements
    for rel in getattr(element, 'ContainsElements', []):
        for child in rel.RelatedElements:
            print(f"{indent}  └─ {child.is_a()}: {child.Name or 'N/A'}")

get_spatial_structure(project)

# Lấy properties
for wall in model.by_type('IfcWall'):
    psets = ifcopenshell.util.element.get_psets(wall)
    print(f"\nWall: {wall.Name}")
    for pset_name, props in psets.items():
        print(f"  {pset_name}:")
        for prop_name, value in props.items():
            print(f"    {prop_name}: {value}")
```

### Chạy service

```bash
cd packages/ifc-import-service
python -m ifc_importer.main

# Hoặc với Docker
docker-compose up ifc-import-service
```

---

## Best Practices

### 1. Memory Management

```javascript
// web-ifc: Luôn close model khi xong
try {
  const modelID = ifcApi.OpenModel(buffer)
  // ... process
} finally {
  ifcApi.CloseModel(modelID)
}
```

```python
# ifcopenshell: Sử dụng context manager nếu có
# hoặc xóa reference khi xong
model = ifcopenshell.open('model.ifc')
# ... process
del model
```

### 2. Error Handling

```javascript
// web-ifc
try {
  const modelID = ifcApi.OpenModel(buffer)
  if (modelID === -1) {
    throw new Error('Failed to open IFC model')
  }
  // ...
} catch (error) {
  console.error('IFC parsing error:', error)
  throw error
}
```

```python
# ifcopenshell
try:
    model = ifcopenshell.open(ifc_path)
except ifcopenshell.Error as e:
    logger.error(f"Failed to open IFC: {e}")
    raise
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    raise
```

### 3. Large File Handling

```javascript
// web-ifc: Sử dụng streaming
ifcApi.StreamAllMeshes(modelID, (mesh) => {
  // Process incrementally
  processMesh(mesh)
})
```

```python
# ifcopenshell: Iterator thay vì list
for element in model.by_type('IfcWall'):
    process_element(element)
    # Don't store all elements in memory
```

### 4. Coordinate Systems

```javascript
// web-ifc: Bật COORDINATE_TO_ORIGIN
const modelID = ifcApi.OpenModel(buffer, {
  COORDINATE_TO_ORIGIN: true
})
```

```python
# ifcopenshell: Set USE_WORLD_COORDS
settings = ifcopenshell.geom.settings()
settings.set(settings.USE_WORLD_COORDS, True)
```

---

## Xử lý lỗi thường gặp

### Lỗi: "WASM module not found"

**Nguyên nhân:** WASM files không được tìm thấy

**Giải pháp:**
```javascript
// Set correct WASM path
await ifcApi.SetWasmPath('./node_modules/web-ifc/')
```

### Lỗi: "Out of memory"

**Nguyên nhân:** File IFC quá lớn

**Giải pháp:**
```bash
# Tăng Node.js memory limit
NODE_OPTIONS="--max-old-space-size=4096" node script.js
```

### Lỗi: "Schema not supported"

**Nguyên nhân:** IFC version không được hỗ trợ

**Giải pháp:**
```python
# Kiểm tra schema trước
model = ifcopenshell.open('model.ifc')
print(f"Schema: {model.schema}")
# Nếu không supported, cần convert file
```

### Lỗi: "Invalid IFC file"

**Nguyên nhân:** File IFC bị corrupt hoặc không hợp lệ

**Giải pháp:**
```python
# Validate file trước
import ifcopenshell.validate
result = ifcopenshell.validate.validate(model)
if result:
    print("Validation errors:", result)
```

### Lỗi: "Geometry extraction failed"

**Nguyên nhân:** Element không có geometry hoặc geometry invalid

**Giải pháp:**
```python
try:
    shape = ifcopenshell.geom.create_shape(settings, element)
except Exception as e:
    logger.warning(f"No geometry for {element.id()}: {e}")
    # Skip or handle missing geometry
```

---

## Debugging Tips

### web-ifc

```javascript
// Enable logging
const modelID = ifcApi.OpenModel(buffer, {
  ENABLE_LOGGING: true
})

// Log all elements
const allIDs = ifcApi.GetAllLines(modelID)
console.log(`Total elements: ${allIDs.size()}`)
```

### ifcopenshell

```python
import logging
logging.basicConfig(level=logging.DEBUG)

# Print element details
def debug_element(element):
    print(f"ID: {element.id()}")
    print(f"Type: {element.is_a()}")
    print(f"Attributes: {element.get_info()}")
```

---

## Tài liệu bổ sung

- [web-ifc API Docs](https://ifcjs.github.io/info/)
- [ifcopenshell Academy](https://academy.ifcopenshell.org/)
- [Speckle Developers Guide](https://speckle.guide/dev/)

---

*Cập nhật lần cuối: 2026-04-13*
