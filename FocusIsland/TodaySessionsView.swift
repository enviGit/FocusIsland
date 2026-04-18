//
//  TodaySessionsView.swift
//  FocusIsland
//
//  Created by Paweł Trojański on 18/04/2026.
//

import SwiftUI
import SwiftData

struct TaskGroup: Identifiable {
    let id: String
    let taskName: String
    let totalDuration: TimeInterval
    let isFavorite: Bool
    let sessions: [FocusSession]
    let latestActivity: Date
}

struct TodaySessionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FocusSession.startDate, order: .reverse) private var sessions: [FocusSession]
    @EnvironmentObject var appState: AppState
    
    @State private var taskInput: String = ""
    @State private var expandedGroups: Set<String> = []
    
    var favoriteTasks: [String] {
        let favs = sessions.filter { $0.isFavorite }
        return Array(Set(favs.map { $0.taskName })).sorted()
    }
    
    var groupedTasks: [TaskGroup] {
        let calendar = Calendar.current
        let todaySessions = sessions.filter { calendar.isDateInToday($0.startDate) }
        
        let grouped = Dictionary(grouping: todaySessions, by: { $0.taskName })
        
        return grouped.compactMap { key, groupSessions in
            let sortedSessions = groupSessions.sorted { $0.startDate > $1.startDate }
            guard let latestSession = sortedSessions.first else { return nil }
            
            let total = sortedSessions.reduce(0.0) { result, session in
                let end = session.endDate ?? Date()
                return result + end.timeIntervalSince(session.startDate)
            }
            
            let isFav = sortedSessions.contains(where: { $0.isFavorite })
            
            return TaskGroup(
                id: key,
                taskName: key,
                totalDuration: total,
                isFavorite: isFav,
                sessions: sortedSessions,
                latestActivity: latestSession.startDate
            )
        }.sorted { $0.latestActivity > $1.latestActivity }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    TextField("What are you working on?", text: $taskInput)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        .onSubmit { toggleCurrentSession() }
                        .onChange(of: taskInput) { oldValue, newValue in
                            if appState.isActive {
                                appState.taskName = newValue
                            }
                        }
                    
                    Button(action: toggleCurrentSession) {
                        Image(systemName: appState.isActive ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(appState.isActive ? .red : .green)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 4)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                if !favoriteTasks.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(favoriteTasks, id: \.self) { favName in
                                Button {
                                    restartExistingTask(name: favName)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 9))
                                            .foregroundColor(.yellow)
                                        Text(favName)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                } else {
                    Spacer().frame(height: 16)
                }
            }
            
            Divider()
            
            if groupedTasks.isEmpty {
                Spacer()
                Text("No sessions today")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(groupedTasks) { taskGroup in
                        let isSingle = taskGroup.sessions.count == 1
                        
                        VStack(spacing: 0) {
                            HStack(alignment: .center) {
                                if !isSingle {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if expandedGroups.contains(taskGroup.id) {
                                                expandedGroups.remove(taskGroup.id)
                                            } else {
                                                expandedGroups.insert(taskGroup.id)
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .rotationEffect(.degrees(expandedGroups.contains(taskGroup.id) ? 90 : 0))
                                            .frame(width: 16)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Spacer().frame(width: 16)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(taskGroup.taskName)
                                            .font(.body)
                                        
                                        if taskGroup.isFavorite {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                        }
                                    }
                                    
                                    if isSingle, let session = taskGroup.sessions.first {
                                        Text("\(session.startDate, format: .dateTime.hour().minute()) - \(session.endDate ?? Date(), format: .dateTime.hour().minute())")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(formatDuration(taskGroup.totalDuration))
                                    .font(.body)
                                    .monospacedDigit()
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 12) {
                                    Button {
                                        restartExistingTask(name: taskGroup.taskName)
                                    } label: {
                                        Image(systemName: "play.fill")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        deleteGroup(taskGroup)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.leading, 8)
                            }
                            .padding(.vertical, 6)
                            .contextMenu {
                                Button("Toggle Favorite") {
                                    toggleFavorite(for: taskGroup.taskName)
                                }
                            }
                            
                            if expandedGroups.contains(taskGroup.id) && !isSingle {
                                ForEach(taskGroup.sessions) { session in
                                    HStack {
                                        Text("\(session.startDate, format: .dateTime.hour().minute()) - \(session.endDate ?? Date(), format: .dateTime.hour().minute())")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(formatDuration(getDuration(of: session)))
                                            .font(.caption)
                                            .monospacedDigit()
                                            .foregroundColor(.secondary)
                                        
                                        Button {
                                            deleteSession(session)
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red.opacity(0.7))
                                                .font(.caption)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.leading, 8)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.leading, 24)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 330, height: 480)
        .onAppear {
            if appState.isActive {
                taskInput = appState.taskName
            }
        }
    }
    
    private func toggleCurrentSession() {
        if appState.isActive {
            if let start = appState.currentSessionStart {
                let duration = Date().timeIntervalSince(start)
                if duration >= 1.0 {
                    let newSession = FocusSession(taskName: appState.taskName, startDate: start)
                    newSession.endDate = Date()
                    modelContext.insert(newSession)
                }
            }
            appState.stopTimer()
            taskInput = ""
        } else {
            let name = taskInput.trimmingCharacters(in: .whitespaces).isEmpty ? "Focusing..." : taskInput
            appState.startTimer(task: name)
        }
    }
    
    private func restartExistingTask(name: String) {
        if appState.isActive {
            toggleCurrentSession()
        }
        taskInput = name
        appState.startTimer(task: name)
    }
    
    private func toggleFavorite(for taskName: String) {
        let relatedSessions = sessions.filter { $0.taskName == taskName }
        let currentFavState = relatedSessions.first?.isFavorite ?? false
        for session in relatedSessions {
            session.isFavorite = !currentFavState
        }
    }
    
    private func deleteSession(_ session: FocusSession) {
        modelContext.delete(session)
    }
    
    private func deleteGroup(_ group: TaskGroup) {
        for session in group.sessions {
            modelContext.delete(session)
        }
    }
    
    private func getDuration(of session: FocusSession) -> TimeInterval {
        let end = session.endDate ?? Date()
        return end.timeIntervalSince(session.startDate)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
