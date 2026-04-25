import SwiftUI
import SwiftData

struct MomentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Moment.createdAt, order: .reverse) private var allMoments: [Moment]

    @State private var selectedDate = Date()
    @State private var weekOffset: Int = 0
    @State private var showingAddMoment = false
    @State private var showingSettings = false
    @State private var navigatingForward = true
    @State private var navigationPath: [Moment] = []
    // Prevents the weekOffset onChange handler firing when the week changes via a day-swipe gesture.
    @State private var suppressWeekOnChange = false

    private var filteredMoments: [Moment] {
        allMoments.filter { $0.createdAt.isSameDay(as: selectedDate) }
    }

    private var momentListTransition: AnyTransition {
        navigatingForward
            ? .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
            : .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
    }

    private func weekOffsetFor(_ date: Date) -> Int {
        Calendar.current.dateComponents(
            [.weekOfYear], from: Date().startOfWeek, to: date.startOfWeek
        ).weekOfYear ?? 0
    }

    private var selectedWeekday: Int {
        Calendar.current.component(.weekday, from: selectedDate)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                Color.nightSky.ignoresSafeArea()

                VStack(spacing: 0) {
                    pageTitle("Moments")

                    weekCalendar
                        .padding(.bottom, 16)

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if filteredMoments.isEmpty {
                                Text("No moments on this day")
                                    .font(.somedayCaption)
                                    .foregroundStyle(Color.starDim)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 40)
                            } else {
                                ForEach(filteredMoments) { moment in
                                    Button {
                                        navigationPath.append(moment)
                                    } label: {
                                        momentCard(moment)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 88)
                    }
                    .id(selectedDate.startOfDay)
                    .transition(momentListTransition)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                                if value.translation.width < -50 {
                                    let next = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                                    guard next.startOfDay <= Date().startOfDay else { return }
                                    navigatingForward = true
                                    let newOffset = weekOffsetFor(next)
                                    if newOffset != weekOffset { suppressWeekOnChange = true }
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        weekOffset = newOffset
                                        selectedDate = next
                                    }
                                } else if value.translation.width > 50 {
                                    let prev = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                                    navigatingForward = false
                                    let newOffset = weekOffsetFor(prev)
                                    if newOffset != weekOffset { suppressWeekOnChange = true }
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        weekOffset = newOffset
                                        selectedDate = prev
                                    }
                                }
                            }
                    )
                }

                bottomBar
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Moment.self) { moment in
                MomentDetailView(moment: moment)
            }
        }
        .sheet(isPresented: $showingAddMoment) {
            AddMomentView(preselectedSomeday: nil, date: selectedDate)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    // MARK: - Week Calendar

    private var weekCalendar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                ForEach(Array(staticDayLabels.enumerated()), id: \.offset) { _, label in
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.starWhite.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)

            TabView(selection: $weekOffset) {
                ForEach(-52...0, id: \.self) { offset in
                    dateBadgeRow(for: offset)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 44)
            .onChange(of: weekOffset) { oldOffset, newOffset in
                guard !suppressWeekOnChange else {
                    suppressWeekOnChange = false
                    return
                }
                navigatingForward = newOffset > oldOffset

                let newWeekStart = Calendar.current.date(
                    byAdding: .weekOfYear, value: newOffset,
                    to: Date().startOfWeek
                ) ?? Date().startOfWeek
                let targetWeekday = selectedWeekday
                let newWeekDates = newWeekStart.weekDates

                if let matchingDate = newWeekDates.first(where: {
                    Calendar.current.component(.weekday, from: $0) == targetWeekday
                }) {
                    let newDate = matchingDate.startOfDay > Date().startOfDay ? Date() : matchingDate
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selectedDate = newDate
                    }
                }
            }
        }
    }

    private var staticDayLabels: [String] {
        Date().startOfWeek.weekDates.map { $0.shortDayName }
    }

    private func dateBadgeRow(for offset: Int) -> some View {
        let weekStart = Calendar.current.date(
            byAdding: .weekOfYear, value: offset,
            to: Date().startOfWeek
        ) ?? Date().startOfWeek

        return HStack(spacing: 0) {
            ForEach(weekStart.weekDates, id: \.self) { date in
                let isFuture = date.startOfDay > Date().startOfDay
                let isSelected = date.isSameDay(as: selectedDate)
                let isToday = date.isToday

                Text("\(date.dayOfMonth)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        isFuture ? Color.starDim :
                        isSelected && isToday ? Color.nearBlack :
                        isSelected ? Color.nightSky :
                        isToday ? Color.sun :
                        Color.starWhite
                    )
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(
                            isFuture ? Color.clear :
                            isSelected && isToday ? Color.sun :
                            isSelected ? Color.starWhite :
                            Color.clear
                        )
                    )
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        guard !isFuture else { return }
                        navigatingForward = date > selectedDate
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedDate = date
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.starWhite)
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }

            Spacer()

            Button {
                showingAddMoment = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.starWhite)
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.nightSky)
    }

    // MARK: - Moment Card

    private func momentCard(_ moment: Moment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(moment.note)
                .font(.somedayBody)
                .foregroundStyle(Color.starWhite)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)

            HStack {
                HStack(spacing: -4) {
                    ForEach(moment.somedays) { someday in
                        Circle()
                            .fill(someday.color)
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(Color.nightSky.opacity(0.6), lineWidth: 1))
                    }
                }
                Spacer()
                if !moment.createdAt.isAtMidnight {
                    Text(moment.createdAt.timeString)
                        .font(.somedayCaption)
                        .foregroundStyle(Color.starDim)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private func pageTitle(_ text: String) -> some View {
    Text(text)
        .font(.somedayTitle)
        .foregroundStyle(Color.starWhite)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 24)
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SomedayItem.self, Moment.self, configurations: config)
    let someday = SomedayItem(title: "Keep in touch with family", colorHex: "#7EC8E3")
    let moment = Moment(note: "Met up with Dad today and went to a cafe in town.", createdAt: Date())
    moment.somedays = [someday]
    container.mainContext.insert(someday)
    container.mainContext.insert(moment)
    return MomentsView()
        .modelContainer(container)
}
