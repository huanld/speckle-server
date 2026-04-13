# 🐍 ifcopenshell + speckleifc - Thư viện IFC cho Python

## Tổng quan

**ifcopenshell** là thư viện C++/Python mạnh mẽ và đầy đủ tính năng nhất để làm việc với file IFC. **speckleifc** là wrapper được Speckle phát triển để convert IFC objects sang Speckle format.

---

## ifcopenshell

### Thông tin cơ bản

| Thuộc tính | Giá trị |
|------------|---------|
| **Ngôn ngữ** | C++ với Python bindings |
| **Package** | `ifcopenshell` |
| **Version trong repo** | 0.8.3 |
| **License** | LGPL-3.0 |
| **Website** | https://ifcopenshell.org |
| **GitHub** | https://github.com/IfcOpenShell/IfcOpenShell |

### Installation

```bash
pip install ifcopenshell==0.8.3
```

### Cách sử dụng cơ bản

```python
import ifcopenshell

# Mở file IFC
model = ifcopenshell.open('model.ifc')

# Lấy tất cả walls
walls = model.by_type('IfcWall')

# Lấy element theo GlobalId
element = model.by_guid('2O2Fr$t4X7Zf8NOew3FL9r')

# Lấy element theo ID
element = model.by_id(123)

# Iterate tất cả elements
for entity in model:
    print(entity.is_a(), entity.id())
```

---

## speckleifc

### Thông tin cơ bản

| Thuộc tính | Giá trị |
|------------|---------|
| **Ngôn ngữ** | Python |
| **Package** | `specklepy[speckleifc]` |
| **Version trong repo** | >= 3.0.7 |
| **GitHub** | https://github.com/specklesystems/speckleifc |

### Cách sử dụng trong Speckle Server

**Vị trí file:**
```
packages/ifc-import-service/src/ifc_importer/process_job.py
```

**Import:**
```python
from speckleifc.main import open_and_convert_file
```

### Convert IFC to Speckle

```python
from speckleifc.main import open_and_convert_file
from specklepy.api.client import SpeckleClient
from specklepy.transports.server import ServerTransport

# Convert IFC file
base_object = open_and_convert_file(
    ifc_path='model.ifc',
    # Các options khác...
)

# Gửi lên Speckle Server
client = SpeckleClient(host='your-speckle-server.com')
transport = ServerTransport(stream_id='your-stream-id', client=client)

# Serialize và gửi
from specklepy.api.operations import send
object_id = send(base=base_object, transports=[transport])
```

---

## API Reference - ifcopenshell

### Đọc thông tin cơ bản

```python
import ifcopenshell

model = ifcopenshell.open('model.ifc')

# Schema version
print(model.schema)  # 'IFC2X3' hoặc 'IFC4'

# Lấy header
print(model.header.file_name.name)

# Đếm entities
print(f"Total entities: {len(list(model))}")
```

### Làm việc với Properties

```python
# Lấy property sets của một element
def get_psets(element):
    psets = {}
    for definition in element.IsDefinedBy:
        if definition.is_a('IfcRelDefinesByProperties'):
            pset = definition.RelatingPropertyDefinition
            if pset.is_a('IfcPropertySet'):
                psets[pset.Name] = {
                    prop.Name: prop.NominalValue.wrappedValue
                    for prop in pset.HasProperties
                    if prop.is_a('IfcPropertySingleValue')
                }
    return psets

wall = model.by_type('IfcWall')[0]
properties = get_psets(wall)
print(properties)
```

### Làm việc với Geometry

```python
import ifcopenshell.geom

# Tạo settings cho geometry
settings = ifcopenshell.geom.settings()
settings.set(settings.USE_WORLD_COORDS, True)

# Lấy geometry của element
shape = ifcopenshell.geom.create_shape(settings, wall)

# Lấy vertices và faces
verts = shape.geometry.verts  # flat list [x1,y1,z1,x2,y2,z2,...]
faces = shape.geometry.faces  # flat list [v1,v2,v3,v1,v2,v3,...]

# Convert sang numpy array
import numpy as np
vertices = np.array(verts).reshape(-1, 3)
triangles = np.array(faces).reshape(-1, 3)
```

### Spatial Structure

```python
# Lấy cấu trúc tòa nhà
project = model.by_type('IfcProject')[0]
site = model.by_type('IfcSite')[0]
building = model.by_type('IfcBuilding')[0]
storeys = model.by_type('IfcBuildingStorey')

# Lấy elements trong một tầng
def get_elements_in_storey(storey):
    elements = []
    for rel in storey.ContainsElements:
        elements.extend(rel.RelatedElements)
    return elements

for storey in storeys:
    print(f"Storey: {storey.Name}")
    elements = get_elements_in_storey(storey)
    print(f"  Elements: {len(elements)}")
```

---

## IFC Types phổ biến

### Building Elements
```python
'IfcWall', 'IfcWallStandardCase'
'IfcSlab'
'IfcDoor'
'IfcWindow'
'IfcColumn'
'IfcBeam'
'IfcStair', 'IfcStairFlight'
'IfcRoof'
'IfcCurtainWall'
'IfcRailing'
'IfcRamp', 'IfcRampFlight'
```

### Spatial Structure
```python
'IfcProject'
'IfcSite'
'IfcBuilding'
'IfcBuildingStorey'
'IfcSpace'
```

### MEP Elements
```python
'IfcFlowSegment'      # Pipes, ducts
'IfcFlowTerminal'     # Fixtures
'IfcFlowFitting'      # Elbows, tees
'IfcEnergyConversionDevice'  # HVAC equipment
```

---

## Ưu điểm

✅ **Đầy đủ tính năng** - Hỗ trợ tất cả IFC entities và relationships  
✅ **Mature & Stable** - Phát triển từ 2011, rất ổn định  
✅ **Geometry processing** - Có module xử lý geometry mạnh mẽ  
✅ **Active community** - Cộng đồng lớn và hỗ trợ tốt  
✅ **IFC4 support** - Hỗ trợ đầy đủ IFC4 và IFC2x3  
✅ **Speckle integration** - Tích hợp sẵn với speckleifc  

## Nhược điểm

❌ **Python dependency** - Cần Python runtime  
❌ **Installation complexity** - Có thể phức tạp trên một số hệ thống  
❌ **Memory usage** - Sử dụng nhiều RAM với file lớn  

---

## Cấu hình trong Speckle Server

### pyproject.toml
```toml
[project]
dependencies = [
    "specklepy[speckleifc]>=3.0.7",
]
```

### requirements.txt
```txt
ifcopenshell==0.8.3  # required for speckleifc
specklepy[speckleifc]>=3.0.7
```

---

## Troubleshooting

### Lỗi Installation trên Windows

```bash
# Sử dụng conda thay vì pip
conda install -c conda-forge ifcopenshell
```

### Lỗi Geometry không render

```python
# Đảm bảo USE_WORLD_COORDS được bật
settings = ifcopenshell.geom.settings()
settings.set(settings.USE_WORLD_COORDS, True)
```

### Lỗi Memory với file lớn

```python
# Sử dụng iterator thay vì load tất cả
for element in model.by_type('IfcWall'):
    # Xử lý từng element
    process_element(element)
    # Giải phóng memory nếu cần
```

---

## Tài liệu tham khảo

- [ifcopenshell Documentation](https://ifcopenshell.org/docs/)
- [ifcopenshell GitHub](https://github.com/IfcOpenShell/IfcOpenShell)
- [speckleifc GitHub](https://github.com/specklesystems/speckleifc)
- [specklepy Documentation](https://speckle.guide/dev/py.html)
- [IFC.js Academy](https://ifcjs.io/academy)

---

*Cập nhật lần cuối: 2026-04-13*
