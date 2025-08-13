enum TeamMode { create, join }

class TeamFlowConfig {
  final String appBarTitle;
  final String step1Title;
  final String step1Helper;
  final String nameHint;
  final bool usePinBoxesForCode;
  final String step2Title;
  final String step2Helper;
  final String codeHint;
  final String confirmLabelStep1;
  final String confirmLabelStep2;

  const TeamFlowConfig({
    required this.appBarTitle,
    required this.step1Title,
    required this.step1Helper,
    required this.nameHint,
    required this.usePinBoxesForCode,
    required this.step2Title,
    required this.step2Helper,
    required this.codeHint,
    required this.confirmLabelStep1,
    required this.confirmLabelStep2,
  });

  static TeamFlowConfig fromMode(TeamMode mode) {
    if (mode == TeamMode.create) {
      return const TeamFlowConfig(
        appBarTitle: "그룹 만들기",
        step1Title: "그룹 만들기",
        step1Helper: "멤버 초대 권한은 방장에게만 있습니다.",
        nameHint: "팀 이름을 입력해 주세요",
        usePinBoxesForCode: true,
        step2Title: "입장코드 설정",
        step2Helper: "그룹에 입장하려면 입장코드가 필요해요.\n잊지 않도록 팀원에게 공유해 주세요.",
        codeHint: "입장코드를 입력해 주세요",
        confirmLabelStep1: "확인",
        confirmLabelStep2: "확인",
      );
    } else {
      return const TeamFlowConfig(
        appBarTitle: "그룹 이름 입력",
        step1Title: "그룹 참가하기",
        step1Helper: "참여할 그룹의 이름을 먼저 입력해 주세요.",
        nameHint: "참여할 팀 이름을 입력해 주세요",
        usePinBoxesForCode: true,
        step2Title: "그룹 입장코드 입력",
        step2Helper: "입장코드는 초대한 친구가 알고 있어요.",
        codeHint: "입장코드 6자리",
        confirmLabelStep1: "다음",
        confirmLabelStep2: "입장코드 확인",
      );
    }
  }
}
