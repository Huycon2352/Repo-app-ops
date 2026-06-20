# Repo-app-ops

Repository này quản lý toàn bộ cấu hình triển khai ứng dụng và hạ tầng Kubernetes theo mô hình **GitOps**, sử dụng **ArgoCD**, **Kustomize** và **Helm**.

Mục tiêu của repository là tách biệt cấu hình hạ tầng, cấu hình ứng dụng và cấu hình từng môi trường nhằm đảm bảo khả năng tái sử dụng, dễ bảo trì và tự động hóa quá trình triển khai trên Kubernetes Cluster.

---

# 🏗️ Kiến trúc Repository

```
.
├── base/
├── apps/
├── argocd/
├── helm-tools/
├── config-setup/
├── app-of-apps.yaml
└── README.md
```

Repository được chia thành các thành phần chính như sau:

- **base/**: Chứa manifest Kubernetes gốc của ứng dụng.
- **apps/**: Chứa các overlay cho từng môi trường triển khai.
- **argocd/**: Chứa các ArgoCD Application phục vụ GitOps.
- **helm-tools/**: Chứa các công cụ cài đặt và quản trị cluster bằng Helm.
- **config-setup/**: Chứa các script khởi tạo cấu hình ban đầu.

---

# 📂 Thư mục `base/`

Thư mục `base/` chứa toàn bộ **manifest Kubernetes chuẩn** của ứng dụng.

Đây là tầng cấu hình gốc (**Base Layer**) và được sử dụng chung cho tất cả các môi trường thông qua **Kustomize Overlay**.

Mỗi service được tách thành một module riêng, bao gồm các tài nguyên như:

- Deployment
- Service
- PersistentVolumeClaim (PVC)
- StorageClass
- Kustomization

```
base/
│
├── db/
├── redis/
├── vote/
├── result/
├── worker/
└── storageclass/
```

### Chức năng từng module

| Module | Mô tả |
|------------|------------------------------------------------|
| **db/** | Cấu hình PostgreSQL Database |
| **redis/** | Cấu hình Redis Cache |
| **vote/** | Frontend nhận phiếu bình chọn |
| **result/** | Frontend hiển thị kết quả |
| **worker/** | Worker xử lý dữ liệu từ Redis sang Database |
| **storageclass/** | Định nghĩa StorageClass cho Persistent Volume |

---

# 📂 Thư mục `apps/`

Thư mục `apps/` chứa các **Kustomize Overlay** dành cho từng môi trường triển khai.

Các overlay sẽ kế thừa manifest từ `base/` và áp dụng các **patch** để thay đổi cấu hình phù hợp với từng môi trường mà không cần chỉnh sửa manifest gốc.

```
apps/
│
├── dev/
├── prod/
├── prod-bluegreen/
└── Scripts/
```

## `dev/`

Overlay dành cho môi trường **Development**.

Bao gồm các patch như:

- PVC
- ImagePullSecret
- NodePort
- Rollout Strategy

Giúp phục vụ quá trình phát triển và kiểm thử ứng dụng.

---

## `prod/`

Overlay dành cho môi trường **Production**.

Chứa các cấu hình tối ưu cho môi trường vận hành chính thức như:

- StorageClass
- Rollout Strategy
- Các patch phục vụ production deployment

---

## `prod-bluegreen/`

Overlay dành cho mô hình triển khai **Blue-Green Deployment**.

Bao gồm:

- Deployment Blue
- Deployment Green
- Service Switch
- Patch chuyển đổi traffic

Chiến lược này giúp triển khai phiên bản mới với **downtime gần như bằng 0** và hỗ trợ rollback nhanh khi xảy ra sự cố.

---

## `Scripts/`

Chứa các script hỗ trợ quá trình triển khai.

Ví dụ:

- tạo ImagePullSecret
- pull secret từ registry
- các script tiện ích phục vụ GitOps

---

# 📂 Thư mục `argocd/`

Thư mục này chứa các manifest kiểu **Application** của ArgoCD.

Đây là nơi định nghĩa:

- Source Repository
- Target Revision
- Destination Cluster
- Namespace
- Sync Policy

```
argocd/
│
├── app-dev.yaml
├── app-prod.yaml
└── app-prod-blue-green.yaml
```

Mỗi file tương ứng với một môi trường triển khai.

| File | Mô tả |
|-----------------------------|--------------------------------|
| `app-dev.yaml` | Deploy môi trường Development |
| `app-prod.yaml` | Deploy môi trường Production |
| `app-prod-blue-green.yaml` | Deploy môi trường Blue-Green |

---

# 📂 File `app-of-apps.yaml`

Repository sử dụng mô hình **App of Apps Pattern** của ArgoCD.

```
app-of-apps.yaml
```

Manifest này đóng vai trò là **Application gốc**, tự động quản lý toàn bộ các ArgoCD Application còn lại.

Chỉ cần triển khai một file duy nhất:

```bash
kubectl apply -f app-of-apps.yaml
```

ArgoCD sẽ tự động đồng bộ toàn bộ các ứng dụng được định nghĩa trong thư mục `argocd/`.

---

# 📂 Thư mục `helm-tools/`

Thư mục này chứa các cấu hình Helm Chart và script cài đặt các công cụ phục vụ vận hành Kubernetes Cluster.

```
helm-tools/
│
├── falco/
├── kyverno/
├── loki/
└── monitoring-stack/
```

## `falco/`

Cài đặt và cấu hình **Falco Runtime Security**.

Bao gồm:

- Custom Rules
- Priority Rules
- Sidekick
- Values
- Script cài đặt

Chức năng:

- Giám sát runtime container
- Phát hiện shell bất thường
- Phát hiện hành vi xâm nhập Pod
- Gửi cảnh báo thời gian thực

---

## `kyverno/`

Cài đặt **Kyverno Policy Engine**.

Bao gồm:

- Security Policy
- Policy Reporter
- Values
- Script triển khai

Một số chính sách tiêu biểu:

- Cấm chạy container privileged
- Kiểm soát securityContext
- Audit và Enforce policy
- Kiểm soát cấu hình Kubernetes trước khi deploy

---

## `loki/`

Cấu hình hệ thống **Logging tập trung**.

Bao gồm:

- Loki Values
- Helm Values
- Script triển khai

Chức năng:

- Thu thập log
- Lưu trữ log tập trung
- Truy vấn log thông qua Grafana

---

## `monitoring-stack/`

Triển khai hệ thống giám sát sử dụng:

- Prometheus
- Grafana
- AlertManager

Bao gồm:

- Helm Values
- Custom Alert Rules
- Script cài đặt

Chức năng:

- Thu thập Metrics
- Dashboard trực quan
- Cảnh báo khi hệ thống gặp sự cố
- Giám sát tài nguyên Cluster

---

# 📂 Thư mục `config-setup/`

Chứa các script khởi tạo cấu hình ban đầu trước khi triển khai GitOps.

Ví dụ:

```
config-secret.sh
```

Script này hỗ trợ:

- tạo Secret
- cấu hình thông tin xác thực
- chuẩn bị môi trường trước khi ArgoCD đồng bộ ứng dụng

---

# 🚀 Triển khai hệ thống

## 1. Khởi tạo Secret

```bash
cd config-setup

chmod +x config-secret.sh

./config-secret.sh
```

---

## 2. Triển khai các công cụ hạ tầng (nếu cần)

Ví dụ:

```bash
cd helm-tools/loki
./setup-loki.sh
```

hoặc

```bash
cd helm-tools/monitoring-stack
./setup.sh
```

---

## 3. Kích hoạt GitOps bằng ArgoCD

```bash
kubectl apply -f app-of-apps.yaml
```

Sau khi Application gốc được tạo, ArgoCD sẽ tự động:

- đồng bộ các Application trong thư mục `argocd/`
- lấy cấu hình từ `apps/`
- áp dụng các Overlay tương ứng
- triển khai ứng dụng lên Kubernetes Cluster

---

# 🔄 Luồng triển khai GitOps

```
Git Repository
        │
        ▼
app-of-apps.yaml
        │
        ▼
ArgoCD Applications
        │
        ▼
apps/ (Overlay)
        │
        ▼
base/ (Manifest gốc)
        │
        ▼
Kubernetes Cluster
```

---

# 🛠️ Công nghệ sử dụng

- Kubernetes
- ArgoCD
- GitOps
- Kustomize
- Helm
- PostgreSQL
- Redis
- Prometheus
- Grafana
- Loki
- Falco
- Kyverno

---

# 📌 Mục tiêu của Repository

- Quản lý hạ tầng theo mô hình GitOps.
- Tách biệt cấu hình giữa Base và Overlay để tăng khả năng tái sử dụng.
- Tự động hóa triển khai thông qua ArgoCD.
- Hỗ trợ nhiều môi trường triển khai (Development, Production, Blue-Green).
- Tích hợp giám sát, logging và bảo mật cho Kubernetes Cluster.
- Dễ dàng mở rộng và bảo trì trong các dự án DevSecOps quy mô lớn.

---
**Repository:** `Repo-app-ops`  
**Mục đích:** Quản lý cấu hình Kubernetes và hạ tầng theo mô hình GitOps phục vụ triển khai và vận hành ứng dụng trên Kubernetes Cluster.
