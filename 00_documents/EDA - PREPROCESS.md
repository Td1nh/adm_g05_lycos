## PHẦN 1. EDA – Phân tích khám phá dữ liệu  
Tôi đề xuất làm 6 mục, theo đúng trình tự dưới đây.  
## 1.1. Khảo sát cấu trúc dữ liệu  
Mục tiêu là hiểu bộ dữ liệu có những gì trước khi xử lý.  

| Nội dung | Kỹ thuật | Kết quả cần có |
| -------------------- | --------------- | -------------------------------------- |
| Kích thước dữ liệu | df.shape | Số dòng, số cột |
| Kiểu dữ liệu | df.info() | Numeric, categorical, datetime |
| Số giá trị phân biệt | df.nunique() | Phát hiện thuộc tính hằng, định danh |
| Giá trị thiếu | df.isna().sum() | Số lượng và tỷ lệ thiếu |
| Dữ liệu trùng | df.duplicated() | Số dòng trùng hoàn toàn |
| Thống kê mô tả | df.describe() | Mean, median, std, min, max, quartiles |
  
Đầu ra: Bảng thống kê tổng quan dữ liệu và bảng chất lượng của từng thuộc tính.  
Chưa xóa hay thay đổi dữ liệu ở bước này.  
  
## 1.2. Phân tích chất lượng dữ liệu  
Tập trung vào 4 vấn đề:  
* Missing values: Thuộc tính nào thiếu nhiều nhất? Thiếu bao nhiêu phần trăm?  
* Duplicate records: Có bao nhiêu bản ghi trùng? Trùng hoàn toàn hay chỉ trùng ID?  
* Invalid values: Có giá trị âm, sai định dạng hoặc nằm ngoài miền hợp lệ không?  
* Outliers: Có giá trị bất thường về mặt thống kê hay nghiệp vụ không?  
Biểu đồ đề xuất: Tỷ lệ giá trị thiếu theo thuộc tính  
Dữ liệu minh họa, không phải kết quả của bộ dữ liệu thực tế.  
Thay tên thuộc tính và giá trị bằng kết quả EDA thực tế.  
Đầu ra: Một bảng vấn đề dữ liệu, trong đó ghi rõ vấn đề phát hiện và phương án xử lý dự kiến. Đây sẽ là cơ sở giải thích cho phần tiền xử lý.  
  
## 1.3. Phân tích phân bố biến mục tiêu  
Đây là phần cần ưu tiên vì đồ án có bài toán Classification.  
Phân tích số lượng quan sát của từng lớp và tỷ lệ phần trăm của chúng. Nếu có mất cân bằng lớp, cần đánh giá mức độ mất cân bằng trước khi quyết định sử dụng kỹ thuật cân bằng.  
  
Ví dụ: 80% thuộc lớp 0, 20% thuộc lớp 1. Đây là số liệu giả định.  
Cần trả lời: Các lớp có cân bằng không? Nếu không, Accuracy liệu có đủ để đánh giá mô hình ở giai đoạn sau?  
  
## 1.4. Phân tích phân bố các thuộc tính  
Chia thành hai nhóm:  

| Loại thuộc tính | Biểu đồ | Mục tiêu |
| --------------- | --------------- | ---------------------------------------- |
| Numeric | Histogram | Quan sát hình dạng phân phối |
| Numeric | Boxplot | Kiểm tra độ phân tán và outlier |
| Categorical | Bar chart | Xem tần suất từng nhóm |
| Categorical | Frequency table | Phát hiện nhóm hiếm, danh mục bất thường |
  
Không cần vẽ tất cả cột vào báo cáo. Nên chọn khoảng 4–6 thuộc tính tiêu biểu dựa trên vai trò nghiệp vụ và vấn đề EDA phát hiện.  
  
## 1.5. Phân tích mối quan hệ giữa thuộc tính và biến mục tiêu  
Mục tiêu là tìm ra các thuộc tính có khả năng hỗ trợ phân lớp.  

| Phân tích | Phương pháp | Ý nghĩa |
| -------------------- | ------------------------ | --------------------------------------------- |
| Numeric – Target | Boxplot theo lớp | Các lớp có khác nhau về phân bố không? |
| Categorical – Target | Crosstab, tỷ lệ theo lớp | Nhóm nào có tỷ lệ xuất hiện lớp mục tiêu cao? |
| Numeric – Numeric | Correlation heatmap | Các thuộc tính có trùng lặp thông tin không? |
| Feature – Target | Mutual Information | Đánh giá mức độ liên quan thống kê |
  
Phần này chỉ là đánh giá khám phá ban đầu, chưa kết luận nên loại thuộc tính nào. Việc lựa chọn chính thức thực hiện trong phần tiền xử lý, dùng tập huấn luyện để tránh rò rỉ thông tin.  
  
## 1.6. Tổng hợp kết quả EDA  
Kết thúc EDA, sếp nên có bảng sau:  

| Phát hiện | Bằng chứng | Hướng xử lý |
| ------------------------------- | ----------------------- | ---------------------------------- |
| Một số cột thiếu dữ liệu | Missing-value chart | Đánh giá điền khuyết hoặc loại |
| Một số dòng trùng | Duplicate count | Xác minh trước khi loại |
| Phân bố lệch mạnh | Histogram | Cân nhắc biến đổi hoặc rời rạc hóa |
| Có outlier | Boxplot | Kiểm tra hợp lệ, không xóa tự động |
| Lớp không cân bằng | Target distribution | Chọn chỉ số đánh giá phù hợp |
| Một số thuộc tính liên quan yếu | Feature–target analysis | Kiểm tra thêm khi chọn thuộc tính |
  
Các hàng chỉ giữ lại khi phát hiện tương ứng thực sự xuất hiện trong dữ liệu.  
  
## PHẦN 2. Tiền xử lý dữ liệu  
## 2.1. Làm sạch dữ liệu  
Căn cứ vào kết quả EDA, triển khai:  

| Vấn đề              | Cách xử lý đề xuất                                    |
| ------------------- | ----------------------------------------------------- |
| Duplicate           | Xóa khi xác minh là bản ghi lặp không hợp lệ          |
| Missing target      | Loại những dòng không có nhãn nếu không thể khôi phục |
| Missing numeric     | Điền median hoặc kỹ thuật phù hợp                     |
| Missing categorical | Điền mode hoặc tạo nhóm Unknown                       |
| Sai định dạng       | Chuẩn hóa kiểu dữ liệu                                |
| Giá trị bất hợp lý  | Sửa nếu có căn cứ, nếu không thì đánh dấu hoặc loại   |
| Outliers            | Kiểm tra nghiệp vụ; không xóa chỉ vì nằm ngoài IQR    |
  
Phải ghi lại số dòng bị loại và số giá trị được xử lý ở từng bước.  
**Lưu ý kỹ thuật: Việc điền khuyết bằng trung vị hoặc mode phải học từ tập train, sau đó áp dụng sang tập test. Không tính những thống kê này trên toàn bộ dữ liệu trước khi chia train/test.**  
  
## 2.2. Phân hạng mức độ quan trọng của thuộc tính  
Đây là nội dung tôi đề xuất đầu tư nhiều nhất.  
Thay vì đơn giản chọn Top 10, sếp có thể kết hợp ba cách đánh giá:  
  
**1. Đánh giá chất lượng và ý nghĩa**  
Missing rate, số giá trị phân biệt, vai trò nghiệp vụ, khả năng gây data leakage.  
  
**2. Đánh giá thống kê**  
Mutual Information để phân hạng mức độ liên quan với biến mục tiêu; correlation để phát hiện khả năng dư thừa thông tin.  
  
**3. Đánh giá qua mô hình**  
So sánh hiệu quả phân lớp khi dùng tất cả thuộc tính hợp lệ và khi dùng bộ thuộc tính được chọn, trên dữ liệu validation.  
  
Kết quả cần có là bảng phân hạng:  

| Thuộc tính | Missing % | MI Score | Quyết định | Lý do                      |
| ---------- | --------- | -------- | ---------- | -------------------------- |
| X1         | …         | …        | Giữ        | Có giá trị dự báo          |
| X2         | …         | …        | Giữ        | Có ý nghĩa nghiệp vụ       |
| X3         | …         | …        | Loại       | Thuộc tính hằng            |
| X4         | …         | …        | Loại       | Chứa thông tin hậu kết quả |
  
Không nên sử dụng một ngưỡng MI tùy ý rồi loại tất cả các thuộc tính dưới ngưỡng đó. Những thuộc tính có giá trị khai phá luật cũng cần được cân nhắc.  
##   
## 2.3. Lựa chọn thuộc tính chính thức  
Tôi đề xuất chia thuộc tính thành ba nhóm.  

| Nhóm | Quyết định |
| ----------------------------------------------- | ------------------------------- |
| Định danh, biến hằng, thông tin rò rỉ mục tiêu | Loại khỏi mô hình |
| Thuộc tính có ý nghĩa và giá trị dự báo | Giữ |
| Thuộc tính thiếu nhiều, dư thừa, liên quan thấp | Thử nghiệm trước khi quyết định |
  
Chú ý: không được loại một cột chỉ vì có tương quan cao với cột khác. Cần kiểm tra liệu việc loại đó có làm giảm hiệu quả mô hình hoặc mất đi những luật có ý nghĩa không.  
##   
## 2.4. Chuẩn bị dữ liệu cho khai phá luật và phân lớp  
Vì đề tài của nhóm yêu cầu cả hai kỹ thuật, tôi khuyến nghị tạo hai dạng biểu diễn dữ liệu từ cùng bộ thuộc tính đã lựa chọn, không tạo hai bộ dữ liệu được làm sạch theo tiêu chuẩn khác nhau.  
Dữ liệu sau làm sạch và lựa chọn thuộc tính  
Cùng tập bản ghi và cùng tập thuộc tính nền  
  
Nhánh Classification  
Encoding, imputation, scaling nếu mô hình yêu cầu.  
Giữ numeric ở dạng phù hợp với mô hình.  
Nhánh Association Rules  
Rời rạc hóa biến liên tục khi cần, mã hóa thành các item.  
Ví dụ: Income=High, Age=Young.  
Cách này giúp nhóm khai phá luật CHARM và FP-Growth, sau đó tạo ba thuộc tính nhị phân Rule_1, Rule_2, Rule_3 để bổ sung vào dữ liệu phân lớp, đúng hướng tài liệu đã ghi.  
  
Về kỹ thuật, nên chia train/test trước khi học các phép biến đổi và khai phá luật có dùng biến mục tiêu. Các luật và ngưỡng rời rạc hóa được xác định từ train, sau đó áp dụng nhất quán cho test.  
  
## 2.5. Thống kê trước và sau tiền xử lý  
Đây là bảng tổng kết quan trọng nhất của phần tiền xử lý.  

| Chỉ tiêu                   | Trước xử lý | Sau xử lý |
| -------------------------- | ----------- | --------- |
| Số dòng dữ liệu            | N₀          | N₁        |
| Số thuộc tính đầu vào      | P₀          | P₁        |
| Số giá trị thiếu           | M₀          | M₁        |
| Số dòng trùng không hợp lệ | D₀          | D₁        |
| Số thuộc tính bị loại      | —           | P₀ − P₁   |
  
Nên bổ sung thêm một bảng nhật ký tiền xử lý để giải thích nguyên nhân dữ liệu thay đổi:  

| Công đoạn | Số dòng bị loại | Số cột bị loại | Lý do |
| ------------------- | --------------- | -------------- | ------------------------------- |
| Loại trùng | … | 0 | Bản ghi lặp |
| Xử lý thiếu nhãn | … | 0 | Không có mục tiêu |
| Loại biến hằng | 0 | … | Không có khả năng phân biệt |
| Lựa chọn thuộc tính | 0 | … | Dựa trên đánh giá và thử nghiệm |
  
##   
## PHẦN 3. Cấu trúc Notebook tôi đề xuất  
Để dễ triển khai, nhóm có thể tổ chức Notebook như sau:  

| Mục | Nội dung                            | Kết quả                       |
| --- | ----------------------------------- | ----------------------------- |
| 01  | Load Data & Data Dictionary         | Bảng mô tả dữ liệu            |
| 02  | EDA – Data Overview                 | Bảng thống kê                 |
| 03  | EDA – Data Quality                  | Missing, duplicate, invalid   |
| 04  | EDA – Target Distribution           | Biểu đồ cân bằng lớp          |
| 05  | EDA – Feature Distribution          | Histogram, boxplot, bar chart |
| 06  | EDA – Feature vs Target             | Crosstab, boxplot, heatmap    |
| 07  | EDA – Findings                      | Bảng tổng hợp phát hiện       |
| 08  | Preprocessing – Data Cleaning       | Dữ liệu sạch                  |
| 09  | Preprocessing – Feature Ranking     | Bảng phân hạng                |
| 10  | Preprocessing – Feature Selection   | Danh sách giữ/loại            |
| 11  | Preprocessing – Data Transformation | Dữ liệu cho ML và ARM         |
| 12  | Preprocessing – Before vs After     | Bảng so sánh cuối             |
  
  
****Nên đưa gì vào báo cáo?****  
Với chương EDA và tiền xử lý, tôi đề xuất khoảng 5–7 biểu đồ và 4 bảng kết quả chính. Không cần đưa mọi biểu đồ đã chạy trong Notebook.  
Các bảng quan trọng gồm thống kê tổng quan, chất lượng dữ liệu, phân hạng/lựa chọn thuộc tính và đối chiếu trước – sau. Biểu đồ nên ưu tiên missing values, phân bố biến mục tiêu, các phân bố thuộc tính tiêu biểu và quan hệ giữa thuộc tính với biến mục tiêu.  
Điểm tôi muốn nhấn mạnh: EDA phải giải thích được dữ liệu đang có vấn đề gì, còn tiền xử lý phải chứng minh được đã xử lý vấn đề đó ra sao và vì sao chọn các thuộc tính cuối cùng.  
Hiện file sếp gửi mới là tài liệu dặn dò, chưa có bộ dữ liệu thực tế. Vì vậy các phương pháp trên là đề xuất triển khai, chưa thể xác định tên cột, ngưỡng xử lý hoặc số lượng thuộc tính cần giữ.  
Nếu sếp gửi dataset (CSV, Excel hoặc Parquet), tôi sẽ dựa trên chính dữ liệu đó để lập một kế hoạch EDA và tiền xử lý cụ thể cho từng thuộc tính, gồm phân tích nào cần chạy, biểu đồ nào thực sự có giá trị, tiêu chí giữ/loại, và code Python tương ứng, thay vì thực hiện các kỹ thuật không cần thiết.  
