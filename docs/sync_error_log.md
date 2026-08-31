# Sync Error Log - 2026-08-31

## CORS 401 (fixed)
```
OPTIONS /api/v1/sync/push 401 Token tidak ada
Access to fetch blocked by CORS: No 'Access-Control-Allow-Origin'
```
**Fix:** `routes.go` CORS middleware + `jwt.go` skip OPTIONS

## FK fails keuskupan_id="" (fixed)
```
Error 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`db_keuskupan`.`jurnal`, CONSTRAINT `fk_keuskupan_jurnal` FOREIGN KEY (`keuskupan_id`) REFERENCES `keuskupan` (`id`))
INSERT INTO `jurnal` (`id`,`keuskupan_id`,...) VALUES ('f162aa54...','',...)
```
**Cause:** `app_database.dart insertJurnalLocal` enqueue payload cuma `{"id":...}` tanpa `keuskupan_id`
**Fix:** FE `app_database.dart` + `master_repository_impl.dart` kirim `jsonEncode` lengkap, BE `sync.go` skip payload kosong

## Sync Success 2026-08-31 13:35:55
```
OPTIONS /api/v1/sync/push 204
record not found SELECT * FROM `keuskupan` WHERE id = '2b40cd88...' -> INSERT keuskupan 1
record not found SELECT * FROM `paroki` WHERE id = '3d98e5e7...' -> INSERT paroki 3
record not found SELECT * FROM `jenis` WHERE id = '4147cf98...' -> INSERT jenis 2
record not found SELECT * FROM `akun` WHERE id = '62b09411...' -> INSERT akun 4
POST /api/v1/sync/push 200 Sync push berhasil (10 items, 4585 bytes)
```
