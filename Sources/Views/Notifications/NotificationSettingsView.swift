import SwiftUI
import UserNotifications

public struct NotificationSettingsView: View {
    @ObservedObject public var viewModel: NotificationViewModel
    public let courses: [Course]
    public let assignments: [Assignment]
    public let onBack: () -> Void

    @State private var customDays: Int = 2
    @State private var customHours: Int = 0
    @State private var selectedHour: Int = 9
    @State private var selectedMinute: Int = 0
    @State private var isTestingNotification: Bool = false

    private let quickDayOptions = [1, 2, 3, 4, 5, 7, 10, 14]

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
                                    isSelected: !viewModel.setting.isCustomOffset && viewModel.setting.daysBefore == 2 && viewModel.setting.hoursBefore == 0
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        customDays = 2
                                        customHours = 0
                                        viewModel.updateOffset(days: 2, hours: 0, isCustom: false)
                                    }
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }

                                presetRow(
                                    title: "1 día antes",
                                    subtitle: "Recordatorio el día previo a la entrega",
                                    isSelected: !viewModel.setting.isCustomOffset && viewModel.setting.daysBefore == 1 && viewModel.setting.hoursBefore == 0
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        customDays = 1
                                        customHours = 0
                                        viewModel.updateOffset(days: 1, hours: 0, isCustom: false)
                                    }
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }

                                presetRow(
                                    title: "3 días antes",
                                    subtitle: "Aviso con suficiente antelación para proyectos largos",
                                    isSelected: !viewModel.setting.isCustomOffset && viewModel.setting.daysBefore == 3 && viewModel.setting.hoursBefore == 0
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        customDays = 3
                                        customHours = 0
                                        viewModel.updateOffset(days: 3, hours: 0, isCustom: false)
                                    }
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }

                                presetRow(
                                    title: "A mi medida (Personalizado)",
                                    subtitle: "Pulsa para elegir con cuántos días de antelación quieres el aviso",
                                    isSelected: viewModel.setting.isCustomOffset
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if customDays < 1 { customDays = 4 }
                                        viewModel.updateOffset(days: customDays, hours: customHours, isCustom: true)
                                    }
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }
                            }

                            // Custom Days & Hours Panel (opens when "A mi medida" is selected)
                            if viewModel.setting.isCustomOffset {
                                VStack(alignment: .leading, spacing: 14) {
                                    Divider()

                                    Text("¿Con cuántos días de antelación quieres que te notifique?")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(GoogleClassroomTheme.blue)

                                    // Quick day selector chips
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(quickDayOptions, id: \.self) { dayOption in
                                                Button(action: {
                                                    customDays = dayOption
                                                    viewModel.updateOffset(days: customDays, hours: customHours, isCustom: true)
                                                    Task { await viewModel.applyToAssignments(assignments) }
                                                }) {
                                                    Text("\(dayOption) \(dayOption == 1 ? "día" : "días")")
                                                        .font(.system(size: 12, weight: customDays == dayOption ? .bold : .medium))
                                                        .foregroundColor(customDays == dayOption ? .white : GoogleClassroomTheme.textPrimary)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(customDays == dayOption ? GoogleClassroomTheme.blue : GoogleClassroomTheme.secondaryBackground)
                                                        .cornerRadius(16)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(customDays == dayOption ? GoogleClassroomTheme.blue : GoogleClassroomTheme.cardBorder, lineWidth: 1)
                                                        )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }

                                    // Fine-grained Stepper for Days
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Días de antelación:")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(GoogleClassroomTheme.textPrimary)
                                            Text("Notificar \(customDays) \(customDays == 1 ? "día" : "días") antes de la entrega")
                                                .font(.system(size: 11))
                                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                                        }
                                        Spacer()
                                        Stepper("\(customDays) \(customDays == 1 ? "día" : "días")", value: $customDays, in: 1...30) { _ in
                                            viewModel.updateOffset(days: customDays, hours: customHours, isCustom: true)
                                            Task { await viewModel.applyToAssignments(assignments) }
                                        }
                                        .font(.system(size: 14, weight: .semibold))
                                    }

                                    // Additional Hours Stepper
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Horas adicionales:")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(GoogleClassroomTheme.textPrimary)
                                            Text("Opcional: suma horas extra de margen")
                                                .font(.system(size: 11))
                                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                                        }
                                        Spacer()
                                        Stepper("\(customHours) h", value: $customHours, in: 0...23) { _ in
                                            viewModel.updateOffset(days: customDays, hours: customHours, isCustom: true)
                                            Task { await viewModel.applyToAssignments(assignments) }
                                        }
                                        .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                                .padding(12)
                                .background(GoogleClassroomTheme.chipBackground.opacity(0.35))
                                .cornerRadius(8)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(16)
                        .background(GoogleClassroomTheme.background)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                        )

                        // Preferred Notification Time (Exact Offset vs Fixed Hour of Day)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(GoogleClassroomTheme.orange)
                                Text("Hora preferida del aviso")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                            }

                            Text("Elige si prefieres que te avise a la misma hora a la que cierra la tarea o a una hora fija:")
                                .font(.system(size: 13))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)

                            VStack(spacing: 8) {
                                let daysText = "\(viewModel.setting.daysBefore) \(viewModel.setting.daysBefore == 1 ? "día" : "días")"

                                presetRow(
                                    title: "Exactamente cuando quedan \(daysText) (misma hora de cierre)",
                                    subtitle: "Ej: Si una tarea cierra el jueves a las 16:00, el aviso llegará a las 16:00 de los días determinados antes",
                                    isSelected: viewModel.setting.notifyAtExactOffset
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.updateNotifyAtExactOffset(true)
                                    }
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }

                                presetRow(
                                    title: "A una hora fija del día",
                                    subtitle: "Recibe el aviso a la hora concreta que elijas (ej. 09:00)",
                                    isSelected: !viewModel.setting.notifyAtExactOffset
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.updateNotifyAtExactOffset(false)
                                    }
                                    Task { await viewModel.applyToAssignments(assignments) }
                                }
                            }

                            if !viewModel.setting.notifyAtExactOffset {
                                Divider()
                                HStack {
                                    Image(systemName: "alarm")
                                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                                    Text("Hora fija del aviso:")
                                        .font(.system(size: 14, weight: .medium))

                                    Spacer()

                                    Picker("Hora", selection: $selectedHour) {
                                        ForEach(0...23, id: \.self) { hour in
                                            Text(String(format: "%02d:00", hour)).tag(hour)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .onChange(of: selectedHour) { newHour in
                                        viewModel.updatePreferredTime(hour: newHour, minute: 0)
                                        Task { await viewModel.applyToAssignments(assignments) }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(16)
                        .background(GoogleClassroomTheme.background)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                        )

                        // Notification Format Preview Card
                        notificationPreviewCard

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
                                let sample = assignments.first(where: { !$0.isSubmitted && $0.dueDate != nil }) ?? assignments.first
                                Task {
                                    await viewModel.sendTestNotification(sampleAssignment: sample)
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

                            Text("Configuración activa: \(viewModel.setting.humanDescription), \(viewModel.setting.timePreferenceDescription).")
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
            Text("Recibirás un banner de prueba en 3 segundos con el formato:\nEntrega [clase]\n[día] [hora] - [nombre de la tarea]")
        }
        .alert("Permisos requeridos", isPresented: $viewModel.showPermissionDeniedAlert) {
            Button("Solicitar permisos") {
                Task { await viewModel.requestPermissions() }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Para recibir recordatorios antes de que terminen tus tareas, debes activar las notificaciones en los Ajustes de iOS.")
        }
    }

    private var notificationPreviewCard: some View {
        let sample = assignments.first(where: { !$0.isSubmitted && $0.dueDate != nil })
        let previewTitle = sample?.notificationTitle ?? "Entrega Programación Multimedia y Dispositivos Móviles"
        let previewBody = sample?.notificationBody ?? "Jueves 16:00 - Práctica 3: Interfaz iOS compatible con Google Classroom"

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "app.badge.fill")
                    .foregroundColor(GoogleClassroomTheme.blue)
                Text("Vista previa de la notificación")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(GoogleClassroomTheme.textPrimary)
            }

            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(GoogleClassroomTheme.blue)
                        .frame(width: 38, height: 38)
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(previewTitle)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text("ahora")
                            .font(.system(size: 11))
                            .foregroundColor(GoogleClassroomTheme.textTertiary)
                    }

                    Text(previewBody)
                        .font(.system(size: 13))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(12)
            .background(GoogleClassroomTheme.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
            )
        }
        .padding(16)
        .background(GoogleClassroomTheme.background)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
        )
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
