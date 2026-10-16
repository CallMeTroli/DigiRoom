import SwiftUI

public struct PeopleTabView: View {
    public let course: Course

    // Sample Digitech FP classmates for DAM / DAW
    private let classmates = [
        "Elena Cano Vidal",
        "Marcos Peña Gómez",
        "Lucía Serrano Castro",
        "David Navarro Ruiz",
        "Sara Ortiz Gil",
        "Javier Méndez López",
        "Paula Castillo Ramos",
        "Carlos Benítez Sanz"
    ]

    public init(course: Course) {
        self.course = course
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Teachers Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Profesores")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(course.bannerColor)

                    Divider()

                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(course.bannerColor)
                                .frame(width: 40, height: 40)
                            Text(course.teacherName.prefix(1))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(course.teacherName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(GoogleClassroomTheme.textPrimary)

                            Text(course.teacherEmail)
                                .font(.system(size: 12))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "envelope")
                            .font(.system(size: 18))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                    }
                    .padding(.vertical, 4)
                }

                // Classmates Section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Compañeros de clase")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(course.bannerColor)

                        Spacer()

                        Text("\(classmates.count) alumnos")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                    }

                    Divider()

                    ForEach(classmates, id: \.self) { name in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#BDC1C6"))
                                    .frame(width: 36, height: 36)
                                Text(name.prefix(1))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text(name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(GoogleClassroomTheme.textPrimary)

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 60)
        }
        .background(GoogleClassroomTheme.background)
    }
}
