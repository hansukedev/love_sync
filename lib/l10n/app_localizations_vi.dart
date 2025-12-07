// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Love Sync';

  @override
  String get settings => 'Cài đặt';

  @override
  String get account => 'Tài khoản';

  @override
  String get appearance => 'Giao diện';

  @override
  String get general => 'Cài đặt chung';

  @override
  String get dangerZone => 'Vùng nguy hiểm';

  @override
  String get editDisplayName => 'Đổi tên hiển thị';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get notifications => 'Thông báo';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get locationSharing => 'Chia sẻ vị trí';

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String get unpair => 'Hủy kết đôi';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get enterYourName => 'Tên của bạn';

  @override
  String get unpairConfirmationTitle => 'Hủy kết đôi?';

  @override
  String get unpairConfirmationContent =>
      'Bạn có chắc chắn muốn rời khỏi mối quan hệ này? Hành động này không thể hoàn tác.';

  @override
  String get unpairAction => 'Hủy kết đôi';

  @override
  String get daysTogether => 'Ngày';

  @override
  String get together => 'Bên nhau';

  @override
  String get anniversary => 'Kỷ niệm';

  @override
  String get tapToPickDate => 'Chạm để chọn ngày';

  @override
  String get partnerFeeling => 'Người ấy đang:';

  @override
  String get didntSayAnything => '(Chưa nói gì cả)';

  @override
  String get yourFeeling => 'Cảm xúc của bạn:';

  @override
  String get whyFeeling => 'Tại sao bạn vui/buồn?';

  @override
  String get updateMood => 'Cập nhật cảm xúc';

  @override
  String get sending => 'Đang gửi...';

  @override
  String get moodUpdated => 'Đã cập nhật cảm xúc!';

  @override
  String get createRoom => 'Tạo Phòng Mới';

  @override
  String get joinRoom => 'Tham Gia Phòng';

  @override
  String get enterCode => 'Nhập mã kết nối';

  @override
  String get waitingForPartner => 'Đang chờ người ấy...';

  @override
  String get copyCode => 'Sao chép mã';

  @override
  String get codeCopied => 'Đã sao chép mã!';

  @override
  String get decisionTournament => 'Giải đấu quyết định';

  @override
  String get helpUsDecide => 'Ăn gì cũng được? Vậy chọn nhé!';

  @override
  String get decisionWon => 'CHỐT ĐƠN!';

  @override
  String get decisionRejected => 'KÈO BỊ TỪ CHỐI!';

  @override
  String get weWill => 'Chúng ta sẽ: ';

  @override
  String get reason => 'Lý do: ';

  @override
  String get moodHappy => 'Vui';

  @override
  String get moodSad => 'Buồn';

  @override
  String get moodAngry => 'Giận';

  @override
  String get moodTired => 'Mệt';

  @override
  String get moodLoved => 'Được yêu';

  @override
  String get connectWithPartner => 'Kết nối với người thương';

  @override
  String get loginFailed => 'Đăng nhập thất bại';

  @override
  String get googleSignInError => 'Lỗi đăng nhập Google';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get signInAnonymously => 'Vào ẩn danh';

  @override
  String get pairingTitle => 'Ghép đôi';

  @override
  String get yourPairingCode => 'Mã ghép đôi của bạn';

  @override
  String get enterPartnerCode => 'Nhập mã của đối phương';

  @override
  String get connect => 'Kết nối';

  @override
  String get copied => 'Đã sao chép!';

  @override
  String get generateCode => 'Tạo mã';

  @override
  String get generateCodeError => 'Không thể tạo mã';

  @override
  String loginError(Object error) {
    return 'Lỗi: $error';
  }

  @override
  String get weHaveBeenTogether => 'Chúng mình bên nhau';

  @override
  String daysCount(Object count) {
    return '$count Ngày';
  }

  @override
  String sinceDate(Object date) {
    return 'Kể từ: $date';
  }

  @override
  String get partnerIsFeeling => 'Người ấy đang cảm thấy...';

  @override
  String get youArePaired => 'Đã kết đôi!';

  @override
  String get howAreYouToday => 'Hôm nay bạn thế nào?';

  @override
  String get whyDoYouFeelThisWay => 'Tại sao bạn cảm thấy vậy?';

  @override
  String get needAtLeastTwoOptions => 'Cần ít nhất 2 lựa chọn!';

  @override
  String get createTournament => 'Tạo Giải Đấu';

  @override
  String get enterOptionsForPartner =>
      'Nhập các lựa chọn để gửi cho người ấy chọn!';

  @override
  String get quantity => 'Số lượng: ';

  @override
  String optionIndex(Object index) {
    return 'Lựa chọn $index';
  }

  @override
  String get send => 'Gửi đi!';

  @override
  String get connectionError => 'Lỗi kết nối hoặc phòng đã bị hủy';

  @override
  String get goBack => 'Quay lại';

  @override
  String get or => 'HOẶC';

  @override
  String partnerFeelingMessage(Object desc, Object mood) {
    return 'Người ấy cảm thấy $mood: $desc';
  }

  @override
  String decisionResult(Object result) {
    return 'Chốt đơn: $result!';
  }

  @override
  String decisionRejectedReason(Object reason) {
    return 'Phản đối: $reason';
  }

  @override
  String get unknownReason => 'Không rõ lý do';

  @override
  String get invitationSent => 'Đã gửi lời mời!';

  @override
  String get editName => 'Edit Name';

  @override
  String get yourName => 'Your Name';

  @override
  String get unpairWarning =>
      'Are you sure you want to unpair? This cannot be undone.';
}
