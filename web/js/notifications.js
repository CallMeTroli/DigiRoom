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
        const parsed = JSON.parse(raw);
        return {
          isEnabled: parsed.isEnabled ?? true,
          daysBefore: parsed.daysBefore ?? 2,
          hoursBefore: parsed.hoursBefore ?? 0,
          isCustomOffset: parsed.isCustomOffset ?? false,
          notifyAtExactOffset: parsed.notifyAtExactOffset ?? false,
          preferredHour: parsed.preferredHour ?? 9,
          soundEnabled: parsed.soundEnabled ?? true,
          perCourseToggles: parsed.perCourseToggles || {}
        };
      } catch (e) {}
    }
    return {
      isEnabled: true,
      daysBefore: 2, // Default: 2 days before (user requirement)
      hoursBefore: 0,
      isCustomOffset: false,
      notifyAtExactOffset: false,
      preferredHour: 9,
      soundEnabled: true,
      perCourseToggles: {}
    };
  }

  saveSettings() {
    localStorage.setItem(this.storageKey, JSON.stringify(this.setting));
  }

  getHumanDescription() {
    if (!this.setting.isCustomOffset && this.setting.daysBefore === 2 && this.setting.hoursBefore === 0) {
      return "2 días antes (Recomendado)";
    } else if (this.setting.daysBefore === 1 && this.setting.hoursBefore === 0) {
      return "1 día antes";
    } else if (this.setting.daysBefore > 1 && this.setting.hoursBefore === 0) {
      return `${this.setting.daysBefore} días antes`;
    } else if (this.setting.daysBefore === 0 && this.setting.hoursBefore > 0) {
      return `${this.setting.hoursBefore} horas antes`;
    } else {
      return `${this.setting.daysBefore} días y ${this.setting.hoursBefore} horas antes`;
    }
  }

  getTimePreferenceDescription() {
    if (this.setting.notifyAtExactOffset) {
      return "exactamente a la misma hora de cierre de la tarea";
    }
    return `a las ${String(this.setting.preferredHour).padStart(2, "0")}:00`;
  }

  formatNotificationForTask(task) {
    const courseName = (task?.courseName || "Programación Multimedia y Dispositivos Móviles").trim();
    const title = `Entrega ${courseName}`;
    let dayAndTime = "Jueves 16:00";

    if (task?.dueDate) {
      const due = new Date(task.dueDate);
      if (!isNaN(due.getTime())) {
        const dayStr = due.toLocaleDateString("es-ES", { weekday: "long" });
        const capDay = dayStr.charAt(0).toUpperCase() + dayStr.slice(1);
        const timeStr = due.toLocaleTimeString("es-ES", { hour: "2-digit", minute: "2-digit", hour12: false });
        dayAndTime = `${capDay} ${timeStr}`;
      }
    }

    const taskName = task?.name || "Práctica 3: Interfaz iOS compatible con Google Classroom";
    const body = `${dayAndTime} - ${taskName}`;
    return { title, body };
  }

  isCourseEnabled(courseId) {
    if (!this.setting.isEnabled) return false;
    return this.setting.perCourseToggles[courseId] !== false;
  }

  toggleCourse(courseId, enabled) {
    this.setting.perCourseToggles[courseId] = enabled;
    this.saveSettings();
  }

  setOffset(days, hours = 0, isCustom = false) {
    this.setting.daysBefore = days;
    this.setting.hoursBefore = hours;
    this.setting.isCustomOffset = isCustom;
    this.saveSettings();
  }

  setNotifyAtExactOffset(exact) {
    this.setting.notifyAtExactOffset = exact;
    this.saveSettings();
  }

  setPreferredHour(hour) {
    this.setting.preferredHour = hour;
    this.setting.notifyAtExactOffset = false;
    this.saveSettings();
  }

  async requestPermission() {
    if ("Notification" in window) {
      const permission = await Notification.requestPermission();
      return permission === "granted";
    }
    return false;
  }

  async sendTestNotification(sampleTask = null) {
    const { title, body } = this.formatNotificationForTask(sampleTask);

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
