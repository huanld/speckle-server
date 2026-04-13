# ⚖️ So sánh các thư viện IFC

Tài liệu này so sánh chi tiết giữa **web-ifc** và **ifcopenshell + speckleifc** được sử dụng trong Speckle Server.

---

## Bảng so sánh tổng quan

| Tiêu chí | web-ifc | ifcopenshell + speckleifc |
|----------|---------|---------------------------|
| **Ngôn ngữ** | JavaScript/WASM | Python/C++ |
| **Package** | fileimport-service | ifc-import-service |
| **IFC2x3** | ✅ | ✅ |
| **IFC4** | ✅ | ✅ |
| **IFC4x3** | ⚠️ Partial | ✅ |
| **Geometry** | ✅ | ✅ |
| **Properties** | ✅ | ✅ |
| **Relationships** | ⚠️ Partial | ✅ |
| **Memory** | Medium | High |
| **Speed** | Fast | Fast |
| **Streaming** | ✅ | ⚠️ Limited |
| **Browser support** | ✅ | ❌ |
| **Speckle native** | ❌ | ✅ |

---

## So sánh chi tiết

### 1. Hiệu suất (Performance)

#### web-ifc
```
📊 Benchmark (100MB IFC file):
- Load time: ~5s
- Memory: ~500MB
- Geometry extraction: ~10s
```

**Ưu điểm:**
- WASM chạy gần native speed
- Streaming API giảm memory footprint
- Tốt cho file nhỏ-trung bình

**Nhược điểm:**
- WASM có memory limits
- Khó xử lý file > 500MB

#### ifcopenshell
```
📊 Benchmark (100MB IFC file):
- Load time: ~8s
- Memory: ~800MB
- Geometry extraction: ~15s
```

**Ưu điểm:**
- Không có memory limits của WASM
- Có thể xử lý file rất lớn (GB+)
- Optimized C++ core

**Nhược điểm:**
- Cần nhiều RAM hơn
- Python overhead

---

### 2. IFC Support

#### web-ifc

| Feature | Support |
|---------|---------|
| IFC2x3 | ✅ Full |
| IFC4 ADD2 | ✅ Full |
| IFC4x3 | ⚠️ Partial |
| Property Sets | ✅ |
| Quantities | ✅ |
| Materials | ✅ |
| Spatial Structure | ✅ |
| Relationships | ⚠️ Basic |
| Complex Geometry | ⚠️ Most |

#### ifcopenshell

| Feature | Support |
|---------|---------|
| IFC2x3 | ✅ Full |
| IFC4 ADD2 | ✅ Full |
| IFC4x3 | ✅ Full |
| Property Sets | ✅ |
| Quantities | ✅ |
| Materials | ✅ |
| Spatial Structure | ✅ |
| Relationships | ✅ Full |
| Complex Geometry | ✅ Full |

---

### 3. API Comparison

#### Đọc file

**web-ifc:**
```javascript
const ifcApi = new WebIFC.IfcAPI()
await ifcApi.Init()
const modelID = ifcApi.OpenModel(buffer)
```

**ifcopenshell:**
```python
import ifcopenshell
model = ifcopenshell.open('model.ifc')
```

#### Lấy elements theo type

**web-ifc:**
```javascript
const wallIDs = ifcApi.GetLineIDsWithType(modelID, WebIFC.IFCWALL)
for (let i = 0; i < wallIDs.size(); i++) {
  const wall = ifcApi.GetLine(modelID, wallIDs.get(i))
}
```

**ifcopenshell:**
```python
walls = model.by_type('IfcWall')
for wall in walls:
    print(wall.Name)
```

#### Lấy Properties

**web-ifc:**
```javascript
const props = ifcApi.GetLine(modelID, elementID, true)
// Manual traversal needed for psets
```

**ifcopenshell:**
```python
import ifcopenshell.util.element
psets = ifcopenshell.util.element.get_psets(element)
```

---

### 4. Use Case Recommendations

| Use Case | Recommended | Reason |
|----------|-------------|--------|
| **Web Viewer** | web-ifc | Browser support, streaming |
| **Server Processing** | ifcopenshell | Full IFC support, stability |
| **Large Files (>500MB)** | ifcopenshell | No WASM memory limits |
| **Real-time Parsing** | web-ifc | Faster initial load |
| **Full Property Access** | ifcopenshell | Better relationship traversal |
| **Speckle Integration** | ifcopenshell + speckleifc | Native Speckle support |
| **Batch Processing** | ifcopenshell | Better for automation |

---

### 5. Integration với Speckle

#### web-ifc (fileimport-service)
```
IFC File → web-ifc → Custom Conversion → Speckle Objects → Server
```
- Cần viết custom conversion code
- Flexibility cao nhưng effort nhiều hơn

#### ifcopenshell + speckleifc (ifc-import-service)
```
IFC File → ifcopenshell → speckleifc → Speckle Objects → Server
```
- Conversion được handle bởi speckleifc
- Out-of-the-box support cho Speckle

---

### 6. Development Experience

| Aspect | web-ifc | ifcopenshell |
|--------|---------|--------------|
| **Documentation** | Good | Excellent |
| **Community** | Growing | Large & Active |
| **Examples** | Many | Many |
| **TypeScript Support** | ✅ | ❌ (Python) |
| **Debugging** | Medium | Easy |
| **Error Messages** | Cryptic | Clear |

---

## Kết luận

### Khi nào dùng web-ifc?
- ✅ Cần chạy trong browser
- ✅ File IFC nhỏ-trung bình (<500MB)
- ✅ Cần streaming/real-time parsing
- ✅ JavaScript/TypeScript environment

### Khi nào dùng ifcopenshell + speckleifc?
- ✅ Server-side processing
- ✅ Cần full IFC support
- ✅ File lớn (>500MB)
- ✅ Tích hợp với Speckle ecosystem
- ✅ Batch processing automation

### Recommendation cho Speckle Server

**Khuyến nghị sử dụng `ifc-import-service` với ifcopenshell + speckleifc** vì:
1. Full IFC support
2. Native Speckle integration
3. Mature và stable
4. Better cho production workloads

---

*Cập nhật lần cuối: 2026-04-13*
