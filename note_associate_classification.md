5. Association Rule Mining – Khai phá luật kết hợp
- Một trong những phần quan trọng nhất của đồ án => khai phá luật phải được sử dụng trực tiếp trong mô hình phân lớp.

5.1. Phải sử dụng hai phương pháp khai phá luật
Thầy yêu cầu:
* Phương pháp thứ nhất: chọn trong ba phương pháp nhóm đã trình bày ở buổi trước (APRIORI)
* Phương pháp thứ hai: chọn thêm từ tài liệu, phần Association Rule Mining cơ bản hoặc nâng cao (FP-GROWTH)
=> lưu ý: không nên lựa chọn hai thuật toán giải quyết hai dạng bài toán quá khác nhau.

5.2. Mỗi phương pháp chỉ cần chọn ba luật
Như vậy, phần kết quả chính có thể trình bày:
Phương pháp	Số luật cần trình bày
Phương pháp A	3
Phương pháp B	3
Tổng cộng để so sánh	6
Lưu ý: 
- Yêu cầu ba luật cho mỗi phương pháp khi so sánh
- Nhưng khi tạo dữ liệu để phân lớp thì chỉ cần dùng ba thuộc tính bổ sung từ một phương pháp được chọn

5.3. So sánh hai phương pháp bằng độ phủ của luật
- Tập trung đánh giá Coverage – độ phủ => luật đó phủ được bao nhiêu phần trăm trong bộ dữ liệu
- Ví dụ như ba cái luật của cái phương pháp Apriori nó chỉ bao phủ khoảng tầm 80%, FP Growth 70% => coverage của Apriori nó hiệu quả hơn
- Không cần đánh giá tốc độ

Bảng nhóm có thể xây dựng:
Tiêu chí	Thuật toán A	Thuật toán B
Số luật chọn	3	3
Độ phủ luật 1	…%	…%
Độ phủ luật 2	…%	…%
Độ phủ luật 3	…%	…%
Độ phủ chung của 3 luật	…%	…%
Lưu ý kỹ thuật: Khi tính độ phủ chung, nên tính tỷ lệ giao dịch được ít nhất một trong ba luật bao phủ, không cộng trực tiếp ba tỷ lệ vì các luật có thể bao phủ trùng giao dịch. 

5.4. Chọn một phương pháp để tạo ba thuộc tính mới
- Đây là bước không được bỏ qua.
- Ví dụ sau khi chọn được ba luật:
* Luật 1: Khách hàng thuộc nhóm A và có đặc điểm B thường có kết quả C.
* Luật 2: Khách hàng có đặc điểm D và E thường có kết quả F.
* Luật 3: Khách hàng thuộc nhóm G thường đồng thời có đặc điểm H. 
=> Có thể tạo ba biến nhị phân cho biết điều kiện của từng luật có được thỏa mãn hay không.
Ví dụ bảng dữ liệu sau khi bổ sung thuộc tính
ID	Biến gốc	Rule_1	Rule_2	Rule_3
01	…	1	0	1
02	…	0	1	0
03	…	1	1	0
Mã 1/0 biểu thị có hoặc không thỏa mãn điều kiện tạo thuộc tính.
=> Điểm bắt buộc là ba feature mới phải được bổ sung vào bảng dữ liệu đã tiền xử lý.

6. Classification – Phân lớp
6.1. Số lượng mô hình
- Chạy 2-3 model ML (có thể tự ý chọn)
- Có thể xem xét Logistic Regression, Decision Tree và Random Forest.
- Việc chọn mô hình phải phù hợp kiểu dữ liệu và mục tiêu phân lớp.

6.2. Phải đánh giá kết quả phân lớp
Thầy đề cập trực tiếp hai chỉ số:
- Accuracy – độ chính xác tổng thể.
- F1-score – chỉ số kết hợp Precision và Recall.
=> Có thể bổ sung Precision, Recall, ma trận nhầm lẫn và các chỉ số phù hợp khác. 

6.3. Nên so sánh phân lớp trước và sau khi thêm luật
Khuyến khích thực hiện
- Trường hợp 1 - Dữ liệu gốc: Chỉ sử dụng các thuộc tính đã tiền xử lý để phân lớp.
- Trường hợp 2 - Dữ liệu bổ sung luật: Thuộc tính gốc + 3 thuộc tính được tạo từ khai phá luật.
=> Sau đó, sử dụng cùng các mô hình phân lớp để so sánh kết quả giữa hai trường hợp.
=> Thầy giải thích thêm rằng việc bổ sung luật không đảm bảo kết quả tốt hơn. Nếu kết quả giảm, nhóm cần kiểm tra nguyên nhân và điều chỉnh.
(trình bày kết quả trung thực, không được tự chọn hoặc điều chỉnh số liệu chỉ để chứng minh rằng khai phá luật giúp tăng hiệu quả)

6.4. Có thể mở rộng thành ba bộ dữ liệu
- Có thể xây dựng ba bộ dữ liệu:
Bộ dữ liệu	Nội dung
D0	Thuộc tính gốc sau tiền xử lý
D1	D0 + 3 thuộc tính từ phương pháp khai phá A
D2	D0 + 3 thuộc tính từ phương pháp khai phá B
- Không bắt buộc phải sử dụng cả hai phương pháp khai phá luật trong bước phân lớp.
- 2 cái thì cũng oki
=> Vì vậy, phương án D0 so với D1 đã phù hợp với hướng thầy đề xuất. D0 – D1 – D2 là hướng làm mở rộng.

7. Phải tách riêng hai loại đánh giá
Đây là phần thầy giải thích nhiều lần do các nhóm bị nhầm.
Nội dung	Đánh giá khai phá luật	Đánh giá phân lớp
Đối tượng	Hai phương pháp khai phá luật	Các mô hình học máy
Kết quả chính	Ba luật của mỗi phương pháp	Kết quả dự đoán lớp
Chỉ số thầy nhấn mạnh	Coverage	Accuracy, F1-score
Mục tiêu	Luật bao phủ bao nhiêu giao dịch?	Mô hình phân lớp hiệu quả thế nào?
Vai trò	Chọn và đánh giá luật	Đánh giá tác dụng của các thuộc tính mới
=> Coverage của luật không thay thế cho Accuracy hay F1-score. Một bộ luật bao phủ được nhiều giao dịch chưa chắc làm cho mô hình phân lớp chính xác hơn.
