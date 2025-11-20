# 06 - Home Feature

**Phase:** 6
**Priority:** HIGH
**Status:** ⚪ TODO
**Estimated:** 7-9 hours

## Description

Implement the Home screen with current GP information, quick stats, and navigation.

## Tasks

### Task 6.1: Home - Providers & State
**Status:** ⚪ TODO
**Time:** 3-4h
**Dependencies:** Task 4.2

**Subtasks:**
- [ ] Create `CurrentGPProvider` (current/next GP)
- [ ] Create `CurrentSessionProvider` (active session)
- [ ] Create `CurrentDriversProvider` (season drivers)
- [ ] Implement refresh logic
- [ ] Handle loading/error/empty states

**Files:**
- `lib/features/home/presentation/providers/current_gp_provider.dart`
- `lib/features/home/presentation/providers/current_gp_provider.g.dart`
- `lib/features/home/presentation/providers/current_session_provider.dart`
- `lib/features/home/presentation/providers/current_drivers_provider.dart`

**Provider Example:**
```dart
@riverpod
class CurrentGP extends _$CurrentGP {
  @override
  Future<Meeting?> build() async {
    final repo = ref.read(meetingsRepositoryProvider);
    final meetings = await repo.getMeetings(meetingKey: 'latest');
    return meetings.isNotEmpty ? meetings.first : null;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
```

### Task 6.2: Home - UI Components
**Status:** ⚪ TODO
**Time:** 4-5h
**Dependencies:** Task 6.1, Task 5.1

**Subtasks:**
- [ ] Create `CurrentGPCard` widget (GP info card)
- [ ] Create `QuickStatsCard` widget (leader, team)
- [ ] Create `NavigationCard` grid (6 cards)
- [ ] Update `HomeScreen` with all components
- [ ] Add pull-to-refresh
- [ ] Implement navigation

**Files:**
- `lib/features/home/presentation/widgets/current_gp_card.dart`
- `lib/features/home/presentation/widgets/quick_stats_card.dart`
- `lib/features/home/presentation/widgets/navigation_card.dart`
- `lib/features/home/presentation/screens/home_screen.dart`

## Screen Layout

```
┌─────────────────────────────────────┐
│  F1Sync               [⚙️ Settings] │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  🏁 PRÓXIMO GP                │ │
│  │  São Paulo Grand Prix         │ │
│  │  🇧🇷 Interlagos               │ │
│  │  ⏰ Em 3 dias, 5h            │ │
│  └───────────────────────────────┘ │
│                                     │
│  Quick Stats                        │
│  ┌─────────────┐ ┌─────────────┐  │
│  │ 🥇 Líder    │ │ 🏎️ Equipes  │  │
│  │ VER - 350pts│ │ Red Bull    │  │
│  └─────────────┘ └─────────────┘  │
│                                     │
│  Navegação Rápida                   │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │ 🏁   │ │ 👤   │ │ 🏢   │       │
│  │ GPs  │ │Driver│ │Teams │       │
│  └──────┘ └──────┘ └──────┘       │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │ 🛣️   │ │ 📊   │ │ ⚙️   │       │
│  │Circuit│Stats │Settings│       │
│  └──────┘ └──────┘ └──────┘       │
└─────────────────────────────────────┘
```

## Widget Specs

### CurrentGPCard
- GP name, location, country flag
- Circuit name
- Date/time with countdown
- Next session indicator
- Tap → Navigate to Meeting Detail

### QuickStatsCard
- Championship leader (name, points)
- Constructor leader (team name)
- Compact, side-by-side layout

### NavigationCard
- Grid of 6 cards: GPs, Drivers, Teams, Circuits, Stats, Settings
- Icon + label
- Gradient background on hover/tap
- Navigate to respective screens

## Dependencies

- Task 4.2 (Repositories)
- Task 5.1 (UI Components)
- intl package for date formatting

## Success Criteria

- [ ] Home screen displays current GP
- [ ] Quick stats showing
- [ ] Navigation working
- [ ] Pull-to-refresh functional
- [ ] Loading states smooth
- [ ] Error handling graceful

## Next Steps

After completion, proceed to Phase 7: Meetings Feature
