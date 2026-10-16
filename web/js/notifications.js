// Customizable Notification Manager for Google Classroom Reminders

export class NotificationSystem {
  constructor() {
    this.storageKey = "digimoodle_notification_setting";
    this.setting = this.loadSettings();
  }

  loadSettings() {
    const raw = localStorage.getItem(this.storageKey);
    if (raw) {
      try {
        return JSON.parse(raw);
      } catch (e) {}
    }
    return {
      isEnabled: true,
      daysBefore: 2, // Default: 2 days before (user requirement)
      hoursBefore: 0,
      preferredHour: 9,
      soundEnabled: true,
      perCourseToggles: {}
    };
  }

  saveSettings() {
    localStorage.setItem(this.storageKey, JSON.stringify(this.setting));
  }

  getHumanDescription() {
    if (this.setting.daysBefore === 2 && this.setting.hoursBefore === 0) {
      return "2 días antes (Recomendado)";
    } else if (this.setting.daysBefore === 1 && this.setting.hoursBefore === 0) {
      return "1 día antes";
    } else if (this.setting.daysBefore === 3 && this.setting.hoursBefore === 0) {
      return "3 días antes";
    } else if (this.setting.daysBefore === 0 && this.setting.hoursBefore > 0) {
      return `${this.setting.hoursBefore} horas antes`;
    } else {
      return `${this.setting.daysBefore} días y ${this.setting.hoursBefore} horas antes`;
    }
  }

  isCourseEnabled(courseId) {
    if (!this.setting.isEnabled) return false;
    return this.setting.perCourseToggles[courseId] !== false;
  }

  toggleCourse(courseId, enabled) {
    this.setting.perCourseToggles[courseId] = enabled;
    this.saveSettings();
  }

  setOffset(days, hours = 0) {
    this.setting.daysBefore = days;
    this.setting.hoursBefore = hours;
    this.saveSettings();
  }

  setPreferredHour(hour) {
    this.setting.preferredHour = hour;
    this.saveSettings();
  }

  async requestPermission() {
    if ("Notification" in window) {
      const permission = await Notification.requestPermission();
      return permission === "granted";
    }
    return false;
  }

  async sendTestNotification() {
    const title = "DigiMoodle · Recordatorio de Tarea";
    const body = `¡Ajuste aplicado! Notificación configurada para '${this.getHumanDescription()}' a las ${String(this.setting.preferredHour).padStart(2, '0')}:00.`;

    if ("Notification" in window && Notification.permission === "granted") {
      new Notification(title, {
        body: body,
        icon: "https://campus.digitechfp.com/pluginfile.php/1/theme_boost_union/favicon/64x64/1791485210/digitech-favicon-512.png"
      });
      return true;
    } else if ("Notification" in window && Notification.permission !== "denied") {
      const perm = await Notification.requestPermission();
      if (perm === "granted") {
        new Notification(title, { body: body });
        return true;
      }
    }
    return false;
  }
}
