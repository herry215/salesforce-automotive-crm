# Salesforce Automotive CRM

현대차그룹 완성차 CRM 프로세스를 Salesforce로 구현하는 개인 학습 프로젝트입니다.

## 프로젝트 배경

현대오토에버 Salesforce 컨설팅팀 재직자의 조언을 참고하여
실제 완성차 CRM 업무 프로세스를 기반으로 설계한 개인 학습 프로젝트입니다.

표준 오브젝트(Asset, Lead, Opportunity, Case)를 우선 활용하는 방향으로 설계했으나,
Developer Edition 환경 제약으로 일부 커스텀 오브젝트를 병행 사용했습니다.

## 프로젝트 소개 (PDF)

👉 [프로젝트 전체 소개 보기 (Google Drive)](https://drive.google.com/file/d/1AprwbhzPA2w9mxZmJlEIYhLj0WXTA9Im/view?usp=sharing)

## 개발 방식

현대오토에버에서도 사내 폐쇄망에서 Claude AI를 도입했다는 소식을 접하고,
이 프로젝트에서도 Claude를 페어 프로그래밍 파트너로 적극 활용했습니다.
설계 방향 검토, 코드 리뷰, 오류 디버깅 전 과정에서 AI와 협업했으며,
제안된 코드는 직접 이해하고 수정하여 Salesforce Org에 배포 및 동작을 확인했습니다.

## 기술 스택

- **Salesforce**: Apex, LWC, SOQL, ConnectAPI
- **Cloud**: Sales Cloud, Service Cloud
- **AI**: Einstein Prompt Builder, Claude Sonnet 4.6
- **Tools**: VS Code, Salesforce CLI, Git

## 데이터 모델 (ERD)

<img src="docs/erd1.png" width="600"/>

## 구현 기능

| 기능          | 설명                                                     |
| ------------- | -------------------------------------------------------- |
| Custom Object | Vehicle**c · ServiceAppointment**c · CustomerSurvey\_\_c |
| Apex Trigger  | 출고완료 시 담당자 Task 자동 생성 (Trigger Handler 패턴) |
| Batch Apex    | A/S 완료 7일 후 고객 설문 자동 발송 (200건 단위 처리)    |
| LWC Dashboard | vehicleDashboard 고객 차량 목록 실시간 조회              |
| Einstein AI   | Prompt Builder + ConnectAPI 연동 고객 피드백 자동 요약   |

## 해당 기술 사용 이유

### Trigger Handler 패턴 선택 이유

Trigger 로직을 Handler 클래스로 분리했습니다. Trigger 파일에 직접 비즈니스 로직을 작성하면
테스트 작성이 어렵고 유지보수가 복잡해지기 때문입니다. Handler 패턴을 적용하면
단위 테스트가 용이하고, 여러 Trigger 이벤트(before/after insert/update)를
하나의 클래스에서 일관성 있게 관리할 수 있습니다.

### Batch Apex 선택 이유

A/S 완료 후 7일이 지난 건을 주기적으로 처리하는 작업에는 Queueable Apex가 아닌
Batch Apex를 선택했습니다. Queueable은 단건 처리에 적합하지만,
실제 운영 환경에서는 하루에 수백~수천 건의 A/S가 완료될 수 있습니다.
Batch Apex는 대량 데이터를 청크 단위로 나눠 처리할 수 있어 안정적입니다.

### Governor Limit 설계 방식

| 항목            | 문제 상황                       | 대응 방식                                         |
| --------------- | ------------------------------- | ------------------------------------------------- |
| SOQL 쿼리       | Trigger 내 반복 SOQL 호출       | Trigger Handler에서 Map으로 일괄 조회             |
| DML 구문        | 건별 insert 반복                | List에 모아서 벌크 insert 처리                    |
| Batch 처리 한도 | 대량 레코드 처리 시 CPU/힙 초과 | `Database.executeBatch(job, 200)` 200건 단위 처리 |

### Einstein AI ConnectAPI 연동

Salesforce Einstein Prompt Builder를 Apex에서 호출할 때
`ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate()` 메서드를 사용합니다.
입력 파라미터는 `Map<String, String>`에 레코드 ID를 `id` 키로 담아
`ConnectApi.WrappedValue`로 감싼 후 전달합니다.
Prompt Builder에서 설정한 리소스 API 이름과 키 이름이 정확히 일치해야 합니다.

## 프로젝트 구조

    force-app/main/default/
    ├── classes/        # Apex 클래스
    ├── triggers/       # Apex Trigger
    ├── lwc/            # Lightning Web Component
    └── objects/        # Custom Object 정의

## 진행 상황

| 단계 | 내용                        | 상태    |
| ---- | --------------------------- | ------- |
| 1    | 데이터 모델 설계 (ERD)      | ✅ 완료 |
| 2    | Custom Object 생성 및 배포  | ✅ 완료 |
| 3    | Apex Trigger / Handler      | ✅ 완료 |
| 4    | Batch Apex (설문 자동 발송) | ✅ 완료 |
| 5    | LWC 고객 대시보드           | ✅ 완료 |
| 6    | Einstein AI 피드백 요약     | ✅ 완료 |
