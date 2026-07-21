# Fruit Pop — Google Play 출시 체크리스트

작업이 끝난 항목과 사용자가 직접 진행해야 할 항목을 분리해 정리했습니다.

---

## ✅ 자동화 완료 (코드/빌드)

| 항목 | 결과 |
|---|---|
| `applicationId` | `io.starjr.fruitpop` |
| Android `namespace` | `io.starjr.fruitpop` |
| Kotlin 패키지 경로 | `android/app/src/main/kotlin/io/starjr/fruitpop/MainActivity.kt` |
| 표시 앱 이름 | `Fruit Pop` (모든 플랫폼) |
| 앱 아이콘 (모든 사이즈) | `assets/icon/app_icon.png` 기반으로 자동 생성됨 |
| Release 키스토어 | `android/fruitpop-release.jks` (10,000일 유효) |
| 키 비밀번호 | `android/key.properties` |
| Release 서명 설정 | `android/app/build.gradle.kts` |
| ProGuard / R8 | 활성화 (코드 축소 + 리소스 축소) |
| 출시용 AAB | `build/app/outputs/bundle/release/app-release.aab` (44.8 MB, 2026-05-08 빌드) |

### ⚠️ 매우 중요 — 절대 잃어버리면 안 되는 두 파일

다음 파일들을 분실하면 **Play Store에 동일한 앱으로 업데이트를 영원히 올릴 수
없습니다.** Play App Signing 으로 옮길 수 있는 시점은 첫 업로드 시뿐이니, 그
전에는 특히 주의:

```
android/fruitpop-release.jks    ← release 키스토어 (RSA 2048bit)
android/key.properties           ← 비밀번호 (storePassword/keyPassword 동일)
```

권장 백업 위치: 1Password / Bitwarden 등 비밀번호 매니저의 “보안 첨부파일”, 또는
완전 사적인 외장 SSD. **공개 GitHub 등에 절대 커밋 금지** (현재 `.gitignore` 에
이미 추가되어 있음).

키스토어 SHA-256 핑거프린트 (Google Play Console에서 확인용):
```
CA:56:EC:25:35:25:A0:E6:FF:61:D3:72:80:5E:4E:7D:1D:C2:DD:B9:48:CC:E2:0D:DA:B3:6D:AE:79:FF:D8:9A
```

---

## 📦 자동화 완료 (스토어 자료)

| 자료 | 위치 | 규격 |
|---|---|---|
| 한국어 스토어 리스팅 | `store/listing_ko.md` | — |
| 영어 스토어 리스팅 | `store/listing_en.md` | — |
| 개인정보처리방침 | `store/privacy_policy.md` | KO + EN 한 파일 |
| 스토어 아이콘 | `store/graphics/store_icon_512.png` | 512×512 PNG |
| 피처 그래픽 | `store/graphics/feature_graphic_1024x500.png` | 1024×500 PNG |
| 폰 스크린샷 ×5 | `store/screenshots/01_home.png` ~ `05_game_intense.png` | 1080×1920 PNG |

---

## 🟡 사용자 직접 작업 (제가 할 수 없는 부분)

순서대로 진행하시면 됩니다.

### 1. Play Console 가입 ($25 일회성)
1. https://play.google.com/console/signup
2. 본인 인증 (정부발행 신분증), 결제 (해외카드 가능)
3. **2024년 정책 변경**: 신규 “개인 계정” 은 가입 후 **신원 확인 검토(7~30일)**
   가 필요합니다. 출시 전에 미리 가입을 시작해 두는 것을 추천합니다.
4. 조직 계정으로 가입하면 D-U-N-S 번호가 필요하고 검토가 더 길지만,
   클로즈드 테스트 의무가 면제됩니다.

### 2. 클로즈드 테스트 12명 / 14일 (개인 계정인 경우 필수)
2024년 11월부터 신규 개인 개발자 계정은 **프로덕션 출시 전에**:
- 클로즈드 테스트 트랙에 12명 이상의 테스터를 14일 이상 등록
- 그 후 “프로덕션 액세스 신청” 을 통해 검수 통과해야 일반 출시 가능

법인 계정은 면제. 미리 친구 / 가족 12명의 Gmail 주소를 모아 두세요.

### 3. 개인정보처리방침 호스팅 ✅ (자동화 완료)
이미 GitHub Pages 로 호스팅되어 있습니다:

```
https://starjr.github.io/fruit_pop/privacy/
```

이 URL 을 Play Console > 메인 스토어 등록정보 > **개인정보처리방침** 에 그대로
입력하세요. 내용은 `docs/privacy.md` 에서 관리되며 GitHub 푸시 후 1~2 분 안에
재배포됩니다 (`store/privacy_policy.md` 와 동기화 유지).

> 연락처 이메일은 `starjr@gmail.com` 으로 두 파일(`store/privacy_policy.md`,
> `lib/data/legal_text.dart`) 에 이미 반영됨. Play Console “개발자 연락처” 에도
> 동일한 이메일을 입력하면 검수 통과율이 높습니다.

### 4. Play Console — 새 앱 만들기
1. “모든 앱” → “앱 만들기”
2. 앱 이름: `Fruit Pop`
3. 기본 언어: 한국어 또는 영어
4. 앱 또는 게임: **게임**
5. 무료/유료: **무료**
6. 선언 항목 모두 ✅
7. “앱 만들기” 클릭

### 5. 메인 스토어 등록정보 입력
- **한국어**: `store/listing_ko.md` 의 내용을 그대로 복사
- **영어**: `store/listing_en.md` (선택, 권장)
- **앱 아이콘**: `store/graphics/store_icon_512.png` 업로드
- **피처 그래픽**: `store/graphics/feature_graphic_1024x500.png` 업로드
- **휴대전화 스크린샷**: `store/screenshots/` 의 1~5번 PNG 모두 업로드 (3장 이상 필수)

### 6. 콘텐츠 등급 (IARC) 설문
"게임" 카테고리 선택 → 폭력/성/언어/도박 모두 “없음” 선택
→ 자동으로 **전체 이용가** 결정

### 7. 데이터 보안 양식
- 앱이 직접 수집·공유하는 계정/연락처 등은 없음
- 쿠팡 파트너스(제휴) 광고·링크가 포함되므로, Play Console 안내에 따라
  **광고 / 제3자** 관련 항목을 재확인·갱신할 것
  (배너·외부 링크로 쿠팡 측 처리가 발생할 수 있음)
- **기기 또는 기타 ID** (광고 ID / ADID): 수집·공유(쿠팡 관심사 배너용)로
  선언. 목적: 광고·마케팅. 사용자가 기기에서 광고 ID 제한 시 전달하지 않음

### 8. 광고
- “앱에 광고가 포함되나요?” → **예**
- 쿠팡 파트너스 배너·제휴 링크 (AdMob 등 일반 광고 네트워크와 별개일 수 있으나
  Play에서는 광고 포함으로 선언)
- 배너 표시: `lib/data/coupang_config.dart` 의 `bannerAdUnitId` 에 파트너스
  배너 임베드 `id` 를 넣은 뒤 빌드
- 제휴 숏링크(권장): 같은 파일의 `affiliateLandingUrl` 에 파트너스에서 복사한
  추적 URL 을 넣기 (비어 있으면 기본 검색+lptag URL 사용)
- ADID/IDFA: 배너 로드 시 읽어 `deviceId` 로 전달 (거부·제한 시 생략)

### 9. 타겟 사용자층 및 콘텐츠
- 타겟 연령: 5세 이상 / 13세 이상 / 18세 이상 중 선택 (**13세 이상 권장** —
  COPPA 정책 회피)
- 가족 정책 준수 여부: 해당 없음

### 10. 앱 액세스
- “앱의 모든 기능에 제한 없이 액세스할 수 있나요?” → **예**

### 11. AAB 업로드
- “출시” → “프로덕션” (또는 처음에는 “클로즈드 테스트”) → 새 출시 만들기
- “Play 앱 서명” 활성화 (권장 — Google이 서명 키를 안전하게 보관)
- `build/app/outputs/bundle/release/app-release.aab` 업로드
- 출시 노트 입력 (예: “초기 출시: 11단계 과일 합치기 퍼즐”)
- “저장” → “검토 시작” → “출시 시작”

### 12. 검수 대기 (보통 1~7일, 첫 출시는 더 길 수 있음)

---

## 향후 업데이트 시

코드 수정 후 새 버전을 올릴 때:

1. `pubspec.yaml` 의 `version: 1.0.0+1` 을 증가:
   - `1.0.0+2`: 같은 표시 버전, 빌드 번호만 +1 (마이너 패치)
   - `1.0.1+2`: 표시 버전과 빌드 번호 둘 다 변경 (마이너 릴리즈)
   - `1.1.0+10`: 메이저 변경
2. `flutter clean && flutter pub get && flutter build appbundle --release`
3. Play Console > 새 출시 만들기 → 새 AAB 업로드

> versionCode (=빌드 번호) 는 **반드시 매번 증가** 해야 합니다. 동일 번호는
> 거부됩니다.

---

## 도움이 필요하시면

각 단계에서 막히면 해당 섹션을 알려주세요. Play Console UI 가 자주 바뀌어서
스크린샷이 다를 수 있는데, 원하시면 화면 캡처 해서 보여 주시면 같이 확인해
드릴 수 있어요.
