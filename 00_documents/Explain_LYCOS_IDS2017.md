# TỪ ĐIỂN DỮ LIỆU LYCOS-IDS2017

Ý nghĩa và ràng buộc của 84 cột gốc trong `02_merge_data/data_raw.csv`.

| Chỉ tiêu | Nội dung |
|---|---|
| Số dòng | 1.837.498 |
| Số cột gốc | 84 |
| Giá trị thiếu / vô cực / trùng toàn dòng | 0 / 0 / 0 |

Ràng buộc là miền hợp lệ đề xuất theo ý nghĩa cột. Khoảng quan sát là min–max trên dữ liệu gốc, không phải ngưỡng cứng. `fwd` = chiều đi; `bwd` = chiều về; `pkt` = gói tin; `IAT` = khoảng thời gian giữa hai gói.

## 1. Định danh luồng và thông tin kết nối

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 1 | `flow_id` | Mã luồng ghép từ IP, cổng và giao thức của hai đầu kết nối. | Chuỗi không rỗng. Không dùng làm khóa duy nhất; một flow_id có thể lặp lại theo thời gian. | 0 thiếu trong mẫu |
| 2 | `src_addr` | Địa chỉ IP của bên khởi tạo luồng. | Địa chỉ IPv4 hợp lệ; không rỗng khi nhận dạng kết nối. | 0 thiếu trong mẫu |
| 3 | `src_port` | Cổng nguồn. | Số nguyên từ 0 đến 65.535; 0 được phép với giao thức không dùng cổng. | 0 – 65,535 |
| 4 | `dst_addr` | Địa chỉ IP của bên nhận luồng. | Địa chỉ IPv4 hợp lệ; không rỗng khi nhận dạng kết nối. | 0 thiếu trong mẫu |
| 5 | `dst_port` | Cổng đích. | Số nguyên từ 0 đến 65.535; 0 được phép với giao thức không dùng cổng. | 0 – 65,529 |
| 6 | `ip_prot` | Mã giao thức trong tiêu đề IP. | Số nguyên từ 0 đến 255; là mã phân loại, không phải đại lượng liên tục. | 1 – 132 |
| 7 | `timestamp` | Thời điểm bắt đầu luồng, tính theo Unix microsecond. | Số nguyên dương; kiểm tra khả năng chuyển thành thời gian hợp lệ. Không coi giá trị lớn là outlier số học. | 1,499,082,997,567,312 – 1,499,457,759,567,285 |

## 2. Thời lượng, kích thước gói và tốc độ toàn luồng

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 8 | `flow_duration` | Thời lượng của luồng. | Số nguyên ≥ 0; đơn vị microsecond (µs). | 0 – 119,999,998 |
| 9 | `down_up_ratio` | Tỷ lệ lưu lượng chiều về so với chiều đi. | Số thực hữu hạn ≥ 0; không có đơn vị. Không áp trần cố định. | 0 – 8.07042 |
| 10 | `pkt_len_max` | Kích thước gói lớn nhất trong luồng. | Số thực hữu hạn ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 24,820 |
| 11 | `pkt_len_min` | Kích thước gói nhỏ nhất trong luồng. | Số thực hữu hạn ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1,448 |
| 12 | `pkt_len_mean` | Kích thước gói trung bình trong luồng. | Số thực hữu hạn ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 2,391.38 |
| 13 | `pkt_len_var` | Phương sai kích thước gói trong luồng. | Số thực hữu hạn ≥ 0; đơn vị byte². Với min/mean/max: min ≤ mean ≤ max. | 0 – 2.68657e+07 |
| 14 | `pkt_len_std` | Độ lệch chuẩn kích thước gói trong luồng. | Số thực hữu hạn ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 5,183.21 |
| 15 | `bytes_per_s` | Số byte truyền trung bình mỗi giây của luồng. | Số thực hữu hạn ≥ 0; đơn vị byte/giây. Giá trị lớn cần đối chiếu thời lượng luồng. | 0 – 1.983e+09 |
| 16 | `pkt_per_s` | Số gói truyền trung bình mỗi giây của luồng. | Số thực hữu hạn ≥ 0; đơn vị gói/giây. | 0 – 2e+06 |
| 17 | `fwd_pkt_per_s` | Số gói chiều đi trung bình mỗi giây. | Số thực hữu hạn ≥ 0; đơn vị gói/giây. | 0 – 2e+06 |
| 18 | `bwd_pkt_per_s` | Số gói chiều về trung bình mỗi giây. | Số thực hữu hạn ≥ 0; đơn vị gói/giây. | 0 – 2e+06 |

## 3. Gói tin theo từng chiều

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 19 | `fwd_pkt_cnt` | Tổng số gói tin chiều đi. | Số nguyên ≥ 0; đơn vị gói. | 0 – 219,759 |
| 20 | `fwd_pkt_len_tot` | Tổng kích thước các gói tin chiều đi. | Số nguyên ≥ 0; đơn vị byte. | 0 – 3,127,392 |
| 21 | `fwd_pkt_len_max` | Kích thước gói lớn nhất chiều đi. | Số nguyên ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 24,820 |
| 22 | `fwd_pkt_len_min` | Kích thước gói nhỏ nhất chiều đi. | Số nguyên ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 2,293 |
| 23 | `fwd_pkt_len_mean` | Kích thước gói trung bình chiều đi. | Số thực hữu hạn ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 5,940.51 |
| 24 | `fwd_pkt_len_std` | Kích thước gói độ lệch chuẩn chiều đi. | Số thực hữu hạn ≥ 0; đơn vị byte. | 0 – 7,127.07 |
| 25 | `fwd_pkt_hdr_len_tot` | Tổng kích thước header của các gói chiều đi. | Số nguyên ≥ 0; đơn vị byte. | 0 – 4,644,908 |
| 26 | `fwd_pkt_hdr_len_min` | Kích thước header nhỏ nhất của gói chiều đi. | Số nguyên ≥ 0; đơn vị byte. | 0 – 44 |
| 27 | `fwd_non_empty_pkt_cnt` | Số gói chiều đi có dữ liệu không rỗng. | Số nguyên từ 0 đến fwd_pkt_cnt. | 0 – 2,388 |
| 28 | `bwd_pkt_cnt` | Tổng số gói tin chiều về. | Số nguyên ≥ 0; đơn vị gói. | 0 – 291,922 |
| 29 | `bwd_pkt_len_tot` | Tổng kích thước các gói tin chiều về. | Số nguyên ≥ 0; đơn vị byte. | 0 – 655,452,323 |
| 30 | `bwd_pkt_len_max` | Kích thước gói lớn nhất chiều về. | Số nguyên ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 19,530 |
| 31 | `bwd_pkt_len_min` | Kích thước gói nhỏ nhất chiều về. | Số nguyên ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1,983 |
| 32 | `bwd_pkt_len_mean` | Kích thước gói trung bình chiều về. | Số thực hữu hạn ≥ 0; đơn vị byte. Với min/mean/max: min ≤ mean ≤ max. | 0 – 4,370.69 |
| 33 | `bwd_pkt_len_std` | Kích thước gói độ lệch chuẩn chiều về. | Số thực hữu hạn ≥ 0; đơn vị byte. | 0 – 6,715.74 |
| 34 | `bwd_pkt_hdr_len_tot` | Tổng kích thước header của các gói chiều về. | Số nguyên ≥ 0; đơn vị byte. | 0 – 5,838,440 |
| 35 | `bwd_pkt_hdr_len_min` | Kích thước header nhỏ nhất của gói chiều về. | Số nguyên ≥ 0; đơn vị byte. | 0 – 44 |
| 36 | `bwd_non_empty_pkt_cnt` | Số gói chiều về có dữ liệu không rỗng. | Số nguyên từ 0 đến bwd_pkt_cnt. | 0 – 291,805 |

## 4. Khoảng cách thời gian giữa các gói (IAT)

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 37 | `iat_max` | Khoảng cách thời gian liên gói lớn nhất toàn luồng. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.2e+08 |
| 38 | `iat_min` | Khoảng cách thời gian liên gói nhỏ nhất toàn luồng. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. Giá trị âm là bất hợp lý; dữ liệu gốc có ngoại lệ cần đánh dấu thiếu. | -14 – 6.9e+07; 2,270 giá trị âm |
| 39 | `iat_mean` | Khoảng cách thời gian liên gói trung bình toàn luồng. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 6.9e+07 |
| 40 | `iat_std` | Khoảng cách thời gian liên gói độ lệch chuẩn toàn luồng. | Số thực hữu hạn ≥ 0; đơn vị µs. | 0 – 8.48192e+07 |
| 41 | `fwd_iat_tot` | Tổng các khoảng cách thời gian liên gói chiều đi. | Số thực hữu hạn ≥ 0; đơn vị µs. | 0 – 119,999,998 |
| 42 | `fwd_iat_max` | Khoảng cách thời gian liên gói lớn nhất chiều đi. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.2e+08 |
| 43 | `fwd_iat_min` | Khoảng cách thời gian liên gói nhỏ nhất chiều đi. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.2e+08 |
| 44 | `fwd_iat_mean` | Khoảng cách thời gian liên gói trung bình chiều đi. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.2e+08 |
| 45 | `fwd_iat_std` | Khoảng cách thời gian liên gói độ lệch chuẩn chiều đi. | Số thực hữu hạn ≥ 0; đơn vị µs. | 0 – 8.3228e+07 |
| 46 | `bwd_iat_tot` | Tổng các khoảng cách thời gian liên gói chiều về. | Số thực hữu hạn ≥ 0; đơn vị µs. | 0 – 119,999,992 |
| 47 | `bwd_iat_max` | Khoảng cách thời gian liên gói lớn nhất chiều về. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.19991e+08 |
| 48 | `bwd_iat_min` | Khoảng cách thời gian liên gói nhỏ nhất chiều về. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.19977e+08 |
| 49 | `bwd_iat_mean` | Khoảng cách thời gian liên gói trung bình chiều về. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.19977e+08 |
| 50 | `bwd_iat_std` | Khoảng cách thời gian liên gói độ lệch chuẩn chiều về. | Số thực hữu hạn ≥ 0; đơn vị µs. | 0 – 8.3273e+07 |

## 5. Giai đoạn hoạt động và nghỉ

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 51 | `active_max` | Thời lượng giai đoạn hoạt động lớn nhất. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.10097e+08 |
| 52 | `active_min` | Thời lượng giai đoạn hoạt động nhỏ nhất. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.10097e+08 |
| 53 | `active_mean` | Thời lượng giai đoạn hoạt động trung bình. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.10097e+08 |
| 54 | `active_std` | Thời lượng giai đoạn hoạt động độ lệch chuẩn. | Số thực hữu hạn ≥ 0; đơn vị µs. | 0 – 7.41544e+07 |
| 55 | `idle_max` | Thời lượng giai đoạn nghỉ lớn nhất. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.2e+08 |
| 56 | `idle_min` | Thời lượng giai đoạn nghỉ nhỏ nhất. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.2e+08 |
| 57 | `idle_mean` | Thời lượng giai đoạn nghỉ trung bình. | Số thực hữu hạn ≥ 0; đơn vị µs. Với min/mean/max: min ≤ mean ≤ max. | 0 – 1.2e+08 |
| 58 | `idle_std` | Thời lượng giai đoạn nghỉ độ lệch chuẩn. | Số thực hữu hạn ≥ 0; đơn vị µs. | 0 – 7.69148e+07 |

## 6. Cờ TCP

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 59 | `flag_SYN` | Số lần/cờ SYN được ghi nhận trong luồng. | Số nguyên ≥ 0. Không ép tất cả cột cờ thành nhị phân vì một số cột là số đếm. | 0 – 52 |
| 60 | `flag_fin` | Số lần/cờ FIN được ghi nhận trong luồng. | Số nguyên ≥ 0. Không ép tất cả cột cờ thành nhị phân vì một số cột là số đếm. | 0 – 1 |
| 61 | `flag_rst` | Số lần/cờ RST được ghi nhận trong luồng. | Số nguyên ≥ 0. Không ép tất cả cột cờ thành nhị phân vì một số cột là số đếm. | 0 – 1 |
| 62 | `flag_ack` | Số lần/cờ ACK được ghi nhận trong luồng. | Số nguyên ≥ 0. Không ép tất cả cột cờ thành nhị phân vì một số cột là số đếm. | 0 – 511,681 |
| 63 | `flag_psh` | Số lần/cờ PSH được ghi nhận trong luồng. | Số nguyên ≥ 0. Không ép tất cả cột cờ thành nhị phân vì một số cột là số đếm. | 0 – 9,861 |
| 66 | `flag_urg` | Số lần/cờ URG được ghi nhận trong luồng. | Số nguyên ≥ 0. Không ép tất cả cột cờ thành nhị phân vì một số cột là số đếm. | 0 – 0 |
| 69 | `flag_cwr` | Số lần/cờ CWR được ghi nhận trong luồng. | Số nguyên ≥ 0. Không ép tất cả cột cờ thành nhị phân vì một số cột là số đếm. | 0 – 23 |
| 70 | `flag_ece` | Số lần/cờ ECE được ghi nhận trong luồng. | Số nguyên ≥ 0. Không ép tất cả cột cờ thành nhị phân vì một số cột là số đếm. | 0 – 2 |
| 64 | `fwd_flag_psh` | Số gói chiều đi có cờ PSH. | Số nguyên từ 0 đến fwd_pkt_cnt. | 0 – 1,589 |
| 67 | `fwd_flag_urg` | Số gói chiều đi có cờ URG. | Số nguyên từ 0 đến fwd_pkt_cnt. | 0 – 0 |
| 65 | `bwd_flag_psh` | Số gói chiều về có cờ PSH. | Số nguyên từ 0 đến bwd_pkt_cnt. | 0 – 9,761 |
| 68 | `bwd_flag_urg` | Số gói chiều về có cờ URG. | Số nguyên từ 0 đến bwd_pkt_cnt. | 0 – 0 |

## 7. Nhóm truyền liên tiếp (bulk)

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 71 | `fwd_bulk_bytes_mean` | Số byte trung bình trong một bulk chiều đi. | Số thực hữu hạn ≥ 0; đơn vị byte. | 0 – 351,373 |
| 72 | `fwd_bulk_pkt_mean` | Số gói trung bình trong một bulk chiều đi. | Số thực hữu hạn ≥ 0; đơn vị gói. | 0 – 360 |
| 73 | `fwd_bulk_rate_mean` | Tốc độ truyền trung bình của các bulk chiều đi. | Số thực hữu hạn ≥ 0; đơn vị byte/giây. | 0 – 9.74e+08 |
| 74 | `bwd_bulk_bytes_mean` | Số byte trung bình trong một bulk chiều về. | Số thực hữu hạn ≥ 0; đơn vị byte. | 0 – 1.56762e+08 |
| 75 | `bwd_bulk_pkt_mean` | Số gói trung bình trong một bulk chiều về. | Số thực hữu hạn ≥ 0; đơn vị gói. | 0 – 58,270.8 |
| 76 | `bwd_bulk_rate_mean` | Tốc độ truyền trung bình của các bulk chiều về. | Số thực hữu hạn ≥ 0; đơn vị byte/giây. | 0 – 1.369e+09 |

## 8. Luồng con (subflow)

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 77 | `fwd_subflow_bytes_mean` | Số byte trung bình trong một luồng con chiều đi. | Số thực hữu hạn ≥ 0; đơn vị byte. | 0 – 1.78398e+06 |
| 78 | `fwd_subflow_pkt_mean` | Số gói trung bình trong một luồng con chiều đi. | Số thực hữu hạn ≥ 0; đơn vị gói. | 0 – 219,759 |
| 79 | `bwd_subflow_bytes_mean` | Số byte trung bình trong một luồng con chiều về. | Số thực hữu hạn ≥ 0; đơn vị byte. | 0 – 6.55452e+08 |
| 80 | `bwd_subflow_pkt_mean` | Số gói trung bình trong một luồng con chiều về. | Số thực hữu hạn ≥ 0; đơn vị gói. | 0 – 291,922 |

## 9. Cửa sổ TCP ban đầu

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 81 | `fwd_tcp_init_win_bytes` | Kích thước cửa sổ TCP ban đầu chiều đi. | Số nguyên -1 hoặc từ 0 đến 65.535 byte; -1 được xem là mã không có/không ghi nhận, không phải kích thước âm. | -1 – 65,535; 887,683 giá trị âm |
| 82 | `bwd_tcp_init_win_bytes` | Kích thước cửa sổ TCP ban đầu chiều về. | Số nguyên -1 hoặc từ 0 đến 65.535 byte; -1 được xem là mã không có/không ghi nhận, không phải kích thước âm. | -1 – 65,535; 898,080 giá trị âm |

## 10. Nhãn và nguồn dữ liệu

| STT | Tên cột | Ý nghĩa | Ràng buộc đề xuất | Khoảng quan sát |
|---:|---|---|---|---|
| 83 | `label` | Nhãn gốc: benign hoặc một loại tấn công. | Chuỗi thuộc đúng 14 nhãn liệt kê ở phần cuối; bắt buộc có khi huấn luyện có giám sát. | 14 nhãn; 0 thiếu |
| 84 | `source_day` | Ngày trong tuần của tệp dữ liệu nguồn. | Một trong Monday, Tuesday, Wednesday, Thursday, Friday; lấy từ tên tệp nguồn. | 5 thứ; 0 thiếu |

## Ngoại lệ và kiểm tra liên cột

- `iat_min` có 2.270 giá trị âm, từ -14 đến -1 µs. Nên đánh dấu thiếu rồi xử lý sau khi chia train/test.
- `fwd_tcp_init_win_bytes` có 887.683 giá trị -1; `bwd_tcp_init_win_bytes` có 898.080 giá trị -1. Xem -1 là mã không có/không ghi nhận.
- Các quan hệ `min ≤ mean ≤ max` và số gói có dữ liệu không vượt tổng số gói đã được kiểm tra, không có dòng vi phạm.
- Giá trị lớn chỉ cần kiểm tra nghiệp vụ; không xóa chỉ vì vượt IQR.
- `is_attack` là cột tạo thêm trong notebook: 0 nếu `label = benign`, 1 với nhãn tấn công. Không có trong 84 cột gốc.

## Nhãn hợp lệ

`benign`, `bot`, `ddos`, `dos_goldeneye`, `dos_hulk`, `dos_slowhttptest`, `dos_slowloris`, `ftp_patator`, `heartbleed`, `portscan`, `ssh_patator`, `webattack_bruteforce`, `webattack_sql_injection`, `webattack_xss`.

`source_day`: `Friday`, `Monday`, `Thursday`, `Tuesday`, `Wednesday`.
