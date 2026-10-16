import SwiftUI
import UserNotifications

public struct NotificationSettingsView: View {
    @ObservedObject public var viewModel: NotificationViewModel
    public let courses: [Course]
    public let assignments: [Assignment]
    public let onBack: () -> Void

    @State private var selectedPresetIndex: Int = 0 // 0: 2 days, 1: 1 day, 2: 3 days, 3: Custom
    @State private var customDays: Int = 2
    @State private var customHours: Int = 0
    @State private var selectedHour: Int = 9
    @State private var selectedMinute: Int = 0
    @State private var isTestingNotification: Bool = false

    public init(
        viewModel: NotificationViewModel,
        courses: [Course],
        assignments: [Assignment],
        onBack: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.courses = courses
        self.assignments = assignments
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .frame(width: 44, height: 44)
                }

                Text("Ajustes de notificaciones")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(GoogleClassroomTheme.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 8)
            .frame(height: 54)
            .background(GoogleClassroomTheme.background)

            Divider()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // System Permission Status Card
                    permissionBanner

                    // Master Toggle
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: Binding(
                            get: { viewModel.setting.isEnabled },
                            set: { enabled in
                                viewModel.toggleMaster(enabled: enabled)
                                Task { await viewModel.applyToAssignments(assignments) }
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Recordatorios de entregas")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                                Text("Recibe avisos antes de la fecha límite de tus tareas del campus.")
                                    .font(.system(size: 13))
                                    .foregroundColor(GoogleClassroomTheme.textSecondary)
                            }
                        }
                        .tint(GoogleClassroomTheme.blue)
                    }
                    .padding(16)
                    .background(GoogleClassroomTheme.background)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                    )

                    if viewModel.setting.isEnabled {
                        // Reminder Offset (Customizable)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "clock.badge.checkmark.fill")
                                    .foregroundColor(GoogleClassroomTheme.blue)
                                Text("¿Con cuánta antelación quieres el aviso?")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                            }

                            Text("Ajusta la antelación a tu medida para no olvidar ninguna entrega:")
                                .font(.system(size: 13))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)

                            // Preset Options
                            VStack(spacing: 8) {
                                presetRow(
                                    title: "2 días antes (Recomendado)",
                                    subtitle: "Aviso óptimo para preparar tu trabajo con margen",
                                    isSelected: viewModel.setting.daysBefore == 2 && viewModel.setting.hoursBefore == 0
                                ) {
                                    viewModel.updateOffset(days: 2, hours: 0)
                                    customDays = 2
                                    customHours = 0
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }

                                presetRow(
                                    title: "1 día antes",
                                    subtitle: "Recordatorio el día previo a la entrega",
                                    isSelected: viewModel.setting.daysBefore == 1 && viewModel.setting.hoursBefore == 0
                                ) {
                                    viewModel.updateOffset(days: 1, hours: 0)
                                    customDays = 1
                                    customHours = 0
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }

                                presetRow(
                                    title: "3 días antes",
                                    subtitle: "Aviso con suficiente antelación para proyectos largos",
                                    isSelected: viewModel.setting.daysBefore == 3 && viewModel.setting.hoursBefore == 0
                                ) {
                                    viewModel.updateOffset(days: 3, hours: 0)
                                    customDays = 3
                                    customHours = 0
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }

                                presetRow(
                                    title: "A mi medida (Personalizado)",
                                    subtitle: "Define el número exacto de días y horas que prefieras",
                                    isSelected: isCustomSelected
                                ) {
                                    viewModel.updateOffset(days: customDays, hours: customHours)
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }
                            }

                            // Custom Steppers (shown if customized)
                            if isCustomSelected {
                                VStack(spacing: 12) {
                                    Divider()
                                    HStack {
                                        Text("Días de antelación:")
                                            .font(.system(size: 14, weight: .medium))
                                        Spacer()
                                        Stepper("\(customDays) días", value: $customDays, in: 0...14) { _ in
                                            viewModel.updateOffset(days: customDays, hours: customHours)
                                            Task { await viewModel.applyToAssignments(assignments) }
                                        }
                                    }

                                    HStack {
                                        Text("Horas adicionales:")
                                            .font(.system(size: 14, weight: .medium))
                                        Spacer()
                                        Stepper("\(customHours) horas", value: $customHours, in: 0...23) { _ in
                                            viewModel.updateOffset(days: customDays, hours: customHours)
                                            Task { await viewModel.applyToAssignments(assignments) }
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(16)
                        .background(GoogleClassroomTheme.background)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                        )

                        // Preferred Notification Time
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(GoogleClassroomTheme.orange)
                                Text("Hora preferida del aviso")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                            }

                            Text("La notificación te llegará el día correspondiente a la hora seleccionada:")
                                .font(.system(size: 13))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)

                            HStack {
                                Image(systemName: "alarm")
                                    .foregroundColor(GoogleClassroomTheme.textSecondary)
                                Text("Hora:")
                                    .font(.system(size: 14, weight: .medium))

                                Spacer()

                                Picker("Hora", selection: $selectedHour) {
                                    ForEach(7...23, id: \.self) { hour in
                                        Text(String(format: "%02d:00", hour)).tag(hour)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: selectedHour) { newHour in
                                    viewModel.updatePreferredTime(hour: newHour, minute: 0)
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }
                            }
                        }
                        .padding(16)
                        .background(GoogleClassroomTheme.background)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                        )

                        // Per-Course Switches
                        if !courses.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "book.fill")
                                        .foregroundColor(GoogleClassroomTheme.green)
                                    Text("Activar por asignatura")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                                }

                                Text("Puedes silenciar o activar asignaturas individualmente:")
                                    .font(.system(size: 13))
                                    .foregroundColor(GoogleClassroomTheme.textSecondary)

                                ForEach(courses) { course in
                                    let isEnabled = viewModel.setting.isCourseEnabled(courseId: course.id)
                                    HStack {
                                        Circle()
                                            .fill(course.bannerColor)
                                            .frame(width: 12, height: 12)

                                        Text(course.fullname)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                                            .lineLimit(1)

                                        Spacer()

                                        Toggle("", isOn: Binding(
                                            get: { isEnabled },
                                            set: { newVal in
                                                viewModel.toggleCourse(courseId: course.id, enabled: newVal)
                                                Task { await viewModel.applyToAssignments(assignments) }
                                            }
                                        ))
                                        .labelsHidden()
                                        .scaleEffect(0.85)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            .padding(16)
                            .background(GoogleClassroomTheme.background)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                            )
                        }

                        // Test Notification Action
                        VStack(spacing: 12) {
                            Button(action: {
                                isTestingNotification = true
                                Task {
                                    await viewModel.sendTestNotification()
                                    isTestingNotification = false
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if isTestingNotification {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "bell.badge.waveform.fill")
                                            .font(.system(size: 16))
                                    }
                                    Text("Probar notificación ahora (en 3 seg)")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(GoogleClassroomTheme.blue)
                                .cornerRadius(8)
                            }

                            Text("Configuración activa: \(viewModel.setting.humanDescription) a las \(String(format: "%02d:%02d", viewModel.setting.preferredHourOfDay, viewModel.setting.preferredMinuteOfDay)).")
                                .font(.system(size: 12))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(GoogleClassroomTheme.secondaryBackground)
        }
        .onAppear {
            customDays = viewModel.setting.daysBefore
            customHours = viewModel.setting.hoursBefore
            selectedHour = viewModel.setting.preferredHourOfDay
        }
        .alert("¡Notificación de prueba programada!", isPresented: $viewModel.showTestSuccessAlert) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text("Recibirás un banner de prueba en tu iPhone en 3 segundos con la configuración a tu medida.")
        }
        .alert("Permisos requeridos", isPresented: $viewModel.showPermissionDeniedAlert) {
            Button("Solicitar permisos") {
                Task { await viewModel.requestPermissions() }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Para recibir recordatorios 2 días antes de que terminen tus tareas, debes activar las notificaciones en los Ajustes de iOS.")
        }
    }

    private var isCustomSelected: Bool {
        let isPreset = (viewModel.setting.daysBefore == 2 && viewModel.setting.hoursBefore == 0) ||
                       (viewModel.setting.daysBefore == 1 && viewModel.setting.hoursBefore == 0) ||
                       (viewModel.setting.daysBefore == 3 && viewModel.setting.hoursBefore == 0)
        return !isPreset
    }

    private var permissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.authorizationStatus == .authorized ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .font(.system(size: 22))
                .foregroundColor(viewModel.authorizationStatus == .authorized ? GoogleClassroomTheme.green : GoogleClassroomTheme.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.authorizationStatus == .authorized ? "Notificaciones permitidas en iOS" : "Permiso de notificaciones pendiente")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                Text(viewModel.authorizationStatus == .authorized ? "Las alertas locales se mostrarán puntualmente." : "Toca aquí para permitir avisos en tu pantalla.")
                    .font(.system(size: 11))
                    .foregroundColor(GoogleClassroomTheme.textSecondary)
            }

            Spacer()

            if viewModel.authorizationStatus != .authorized {
                Button("Activar") {
                    Task { await viewModel.requestPermissions() }
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(GoogleClassroomTheme.blue)
            }
        }
        .padding(12)
        .background(
            (viewModel.authorizationStatus == .authorized ? GoogleClassroomTheme.green : GoogleClassroomTheme.orange).opacity(0.1)
        )
        .cornerRadius(8)
    }

    private func presetRow(
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? GoogleClassroomTheme.blue : GoogleClassroomTheme.textTertiary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                }

                Spacer()
            }
            .padding(12)
            .background(isSelected ? GoogleClassroomTheme.chipBackground.opacity(0.6) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
