# Agent Decision Workbench

**Claude Code + Codex CLI + CAO + Composio + Jev**를 하나의 반복 가능한 개발 흐름으로 묶기 위한 로컬 우선 스타터입니다.

핵심은 새로운 오케스트레이터를 또 만드는 것이 아닙니다.

- Claude Code: Supervisor
- Claude Code: Developer
- Codex: 독립 Reviewer / Quality Gate
- CAO: 세션/에이전트 오케스트레이션
- Composio: 외부 툴 연결/인증
- Jev: 애매한 분기에서 구조화된 판단

## 빠른 시작

```bash
chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

Jev가 아직 Composio에 연결되지 않았다면:

```bash
composio link jev
```

환경 검사:

```bash
./scripts/doctor.sh
```

Supervisor 실행:

```bash
./scripts/launch.sh
```

## 이 레포가 지키는 원칙

Jev는 테스트나 컴파일 결과를 대신하지 않습니다.

다음처럼 **실제 다음 행동이 달라지는 애매한 판단**에만 사용합니다.

- Codex에게 맡길지 Claude에게 맡길지
- 추가 조사가 필요한지
- 리뷰를 더 할지
- 수정할지 승인할지
- 사람 확인으로 넘길지

반대로 파일 확인, 테스트 성공 여부, 명백한 구현 절차 같은 것은 직접 증거를 우선합니다.

현재 버전은 v0.1 실험용입니다. 실제 작업에서 생산성이 올라가는지 측정한 뒤 필요한 기능만 추가하는 것을 목표로 합니다.
