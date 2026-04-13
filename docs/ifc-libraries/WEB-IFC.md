# 🔧 web-ifc - Thư viện IFC cho JavaScript

## Tổng quan

**web-ifc** là một thư viện WebAssembly (WASM) để đọc và ghi file IFC trong môi trường JavaScript/TypeScript. Thư viện này được phát triển bởi IFC.js team.

## Thông tin cơ bản

| Thuộc tính | Giá trị |
|------------|---------|
| **Ngôn ngữ** | C++ (compiled to WASM) |
| **Runtime** | Browser / Node.js |
| **Package** | `web-ifc` |
| **License** | Mozilla Public License 2.0 |
| **GitHub** | https://github.com/IFCjs/web-ifc |
| **NPM** | https://www.npmjs.com/package/web-ifc |

---

## Cách sử dụng trong Speckle Server

### Vị trí file

```
packages/fileimport-service/src/ifc/parser.js
```

### Import

```javascript
import WebIFC from 'web-ifc/web-ifc-api-node.js'
```

### Khởi tạo cơ bản

```javascript
const ifcApi = new WebIFC.IfcAPI()

// Khởi tạo với WASM path
await ifcApi.Init()

// Hoặc với custom settings
await ifcApi.SetWasmPath('./path/to/wasm/')
```

---

## API Reference

### Đọc file IFC

```javascript
// Đọc file từ buffer
const modelID = ifcApi.OpenModel(uint8Array, {
  COORDINATE_TO_ORIGIN: true,
  USE_FAST_BOOLS: true
})

// Lấy thông tin geometry
const geometry = ifcApi.GetGeometry(modelID, expressID)

// Lấy properties
const properties = ifcApi.GetLine(modelID, expressID)

// Đóng model khi xong
ifcApi.CloseModel(modelID)
```

### Lấy tất cả elements theo type

```javascript
// Lấy tất cả IfcWall
const walls = ifcApi.GetLineIDsWithType(modelID, WebIFC.IFCWALL)

// Lấy tất cả IfcSlab
const slabs = ifcApi.GetLineIDsWithType(modelID, WebIFC.IFCSLAB)

// Lấy tất cả IfcDoor
const doors = ifcApi.GetLineIDsWithType(modelID, WebIFC.IFCDOOR)
```

### Streaming API (Large files)

```javascript
// Sử dụng streaming cho file lớn
ifcApi.StreamAllMeshes(modelID, (mesh) => {
  // Xử lý từng mesh
  const placedGeometry = mesh.geometries
  // ...
})
```

---

## Cấu hình Settings

```javascript
const settings = {
  // Di chuyển model về origin
  COORDINATE_TO_ORIGIN: true,
  
  // Sử dụng fast boolean operations
  USE_FAST_BOOLS: true,
  
  // Circle segments (ảnh hưởng quality của curves)
  CIRCLE_SEGMENTS: 12,
  
  // Bật/tắt logging
  ENABLE_LOGGING: false
}

const modelID = ifcApi.OpenModel(buffer, settings)
```

---

## IFC Types thường dùng

```javascript
// Building Elements
WebIFC.IFCWALL
WebIFC.IFCWALLSTANDARDCASE
WebIFC.IFCSLAB
WebIFC.IFCDOOR
WebIFC.IFCWINDOW
WebIFC.IFCCOLUMN
WebIFC.IFCBEAM
WebIFC.IFCSTAIR
WebIFC.IFCROOF
WebIFC.IFCFURNISHINGELEMENT

// Spatial Structure
WebIFC.IFCPROJECT
WebIFC.IFCSITE
WebIFC.IFCBUILDING
WebIFC.IFCBUILDINGSTOREY
WebIFC.IFCSPACE

// Properties
WebIFC.IFCPROPERTYSET
WebIFC.IFCPROPERTYSINGLEVALUE
WebIFC.IFCRELDEFINESBYPROPERTIES
```

---

## Ưu điểm

✅ **Hiệu suất cao** - WebAssembly chạy gần như native speed  
✅ **Cross-platform** - Chạy được trên Browser và Node.js  
✅ **Streaming support** - Xử lý được file lớn  
✅ **No external dependencies** - Self-contained WASM module  
✅ **Active development** - Được maintain bởi IFC.js community  

## Nhược điểm

❌ **Memory constraints** - WASM có giới hạn bộ nhớ  
❌ **Limited IFC support** - Không hỗ trợ đầy đủ tất cả IFC entities  
❌ **Learning curve** - API có thể phức tạp với người mới  

---

## Troubleshooting

### Lỗi WASM không load được

```javascript
// Đảm bảo WASM path đúng
await ifcApi.SetWasmPath('/node_modules/web-ifc/')
```

### Lỗi Out of Memory

```javascript
// Sử dụng streaming thay vì load toàn bộ
ifcApi.StreamAllMeshes(modelID, (mesh) => {
  // Process incrementally
})
```

### Lỗi với coordinate system

```javascript
// Bật COORDINATE_TO_ORIGIN
const modelID = ifcApi.OpenModel(buffer, {
  COORDINATE_TO_ORIGIN: true
})
```

---

## Tài liệu tham khảo

- [web-ifc GitHub](https://github.com/IFCjs/web-ifc)
- [IFC.js Documentation](https://ifcjs.io/docs/)
- [NPM Package](https://www.npmjs.com/package/web-ifc)

---

*Cập nhật lần cuối: 2026-04-13*
