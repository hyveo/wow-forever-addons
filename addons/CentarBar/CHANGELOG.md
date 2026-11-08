# 변경 내역

## 1.62 — 2026-11-08

- 몬스터와 전투 중에 재사용 대기시간 숫자가 사라지던 문제 수정
  - 원인: 포에버(Midnight 기반)는 전투 중 쿨다운 값을 비밀 값(secret value)으로 넘겨주는데, 애드온이 그 값을 직접 비교·계산하다 실패해 숫자가 표시되지 않음
  - 숫자를 블리자드 기본 쿨다운 숫자 기능으로 표시하도록 변경 (`C_ActionBar.GetActionCooldownDuration` → `SetCooldownFromDurationObject`)
  - 기존 디자인(20pt 외곽선, 골드색) 유지, 글로벌 쿨다운 중에는 숫자 숨김
  - 직접 계산하던 타이머와 주문별 쿨다운 목록 제거 → 모든 직업에 동일하게 적용
  - 충전 횟수·소모품 개수, 아이콘 색상·체크 상태 판정도 전투 중 오류 없이 동작하도록 수정

![1.62 수정 전후](docs/v1.62-before-after.png)

## 1.61 — 2026-11-07

- 와우 포에버 정식 클라이언트에서 애드온 목록에 **미호환**으로 표시되어 로드되지 않던 문제 수정
  - TOC의 Interface 번호에 출시 클라이언트 번호 `16002` 추가 (기존 `16001`은 베타 번호)
  - 포에버 전용 TOC(`CentarBar_Forever.toc`, `CentarBar_Option_Forever.toc`) 추가

![1.61 수정 전후](docs/v1.61-before-after.png)

## 1.60

- 원본 (Clamp, zico)
