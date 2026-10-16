import { DEMO_USER, DEMO_COURSES, DEMO_ANNOUNCEMENTS, DEMO_TOPICS } from "./demo-data.js";
import { MoodleAPI } from "./moodle-api.js";
import { NotificationSystem } from "./notifications.js";

class App {
  constructor() {
    this.api = new MoodleAPI();
    this.notifications = new NotificationSystem();

    this.currentUser = null;
    this.courses = [];
    this.activeCourse = null;
    this.activeAssignment = null;
    this.activeTab = "stream";
    this.activeTodoTab = "assigned";

    this.init();
  }

  init() {
    this.bindEvents();

    const savedUser = localStorage.getItem("digimoodle_user");
    if (savedUser) {
      try {
        this.currentUser = JSON.parse(savedUser);
        this.loadCourses();
        this.showView("courses");
        return;
      } catch (e) {}
    }

    this.showView("login");
  }

  bindEvents() {
    // Menu Drawer Toggle
    document.getElementById("btn-menu")?.addEventListener("click", () => this.toggleDrawer(true));
    document.getElementById("drawer-backdrop")?.addEventListener("click", () => this.toggleDrawer(false));

    // Drawer Navigation
    document.getElementById("nav-classes")?.addEventListener("click", () => {
      this.toggleDrawer(false);
      this.showView("courses");
    });
    document.getElementById("nav-todo")?.addEventListener("click", () => {
      this.toggleDrawer(false);
      this.showView("todo");
      this.renderTodoList();
    });
    document.getElementById("nav-notifications")?.addEventListener("click", () => {
      this.toggleDrawer(false);
      this.showView("notifications");
      this.renderNotificationSettings();
    });
    document.getElementById("nav-logout")?.addEventListener("click", () => {
      this.toggleDrawer(false);
      this.logout();
    });

    // Profile Avatar
    document.getElementById("btn-avatar")?.addEventListener("click", () => this.showProfileModal());

    // Login actions
    document.getElementById("login-form")?.addEventListener("submit", (e) => {
      e.preventDefault();
      this.handleLogin();
    });
    document.getElementById("btn-demo-mode")?.addEventListener("click", () => this.handleDemoLogin());

    // Back Buttons
    document.getElementById("btn-back-course")?.addEventListener("click", () => this.showView("courses"));
    document.getElementById("btn-back-assignment")?.addEventListener("click", () => {
      if (this.activeCourse) {
        this.showView("course-detail");
      } else {
        this.showView("courses");
      }
    });
    document.getElementById("btn-back-todo")?.addEventListener("click", () => this.showView("courses"));
    document.getElementById("btn-back-notifications")?.addEventListener("click", () => this.showView("courses"));

    // Course Bottom Tabs
    document.querySelectorAll(".nav-tab").forEach(tab => {
      tab.addEventListener("click", (e) => {
        const tabName = tab.dataset.tab;
        this.switchCourseTab(tabName);
      });
    });

    // Todo Tabs
    document.querySelectorAll(".todo-tab").forEach(tab => {
      tab.addEventListener("click", (e) => {
        document.querySelectorAll(".todo-tab").forEach(t => t.classList.remove("active"));
        tab.classList.add("active");
        this.activeTodoTab = tab.dataset.tab;
        this.renderTodoList();
      });
    });
  }

  toggleDrawer(open) {
    const drawer = document.getElementById("side-drawer");
    const backdrop = document.getElementById("drawer-backdrop");
    if (open) {
      drawer?.classList.add("open");
      backdrop?.classList.add("open");
    } else {
      drawer?.classList.remove("open");
      backdrop?.classList.remove("open");
    }
  }

  showView(viewName) {
    document.querySelectorAll(".view-section").forEach(sec => sec.style.display = "none");
    const target = document.getElementById(`view-${viewName}`);
    if (target) target.style.display = "block";

    // Update Header visibility
    const topBar = document.getElementById("app-top-bar");
    const courseBar = document.getElementById("course-top-bar");
    const todoBar = document.getElementById("todo-top-bar");
    const notifBar = document.getElementById("notif-top-bar");
    const bottomNav = document.getElementById("course-bottom-nav");

    topBar.style.display = "none";
    courseBar.style.display = "none";
    todoBar.style.display = "none";
    notifBar.style.display = "none";
    bottomNav.style.display = "none";

    if (viewName === "courses") {
      topBar.style.display = "flex";
      this.renderCourses();
    } else if (viewName === "course-detail") {
      courseBar.style.display = "flex";
      bottomNav.style.display = "flex";
      this.renderCourseDetail();
    } else if (viewName === "todo") {
      todoBar.style.display = "flex";
    } else if (viewName === "notifications") {
      notifBar.style.display = "flex";
    }
  }

  async handleLogin() {
    const userField = document.getElementById("input-username");
    const passField = document.getElementById("input-password");
    const errorBox = document.getElementById("login-error");
    const btnSubmit = document.getElementById("btn-submit-login");

    errorBox.style.display = "none";
    btnSubmit.disabled = true;
    btnSubmit.innerText = "Conectando con campus...";

    try {
      const user = await this.api.login(userField.value, passField.value);
      this.currentUser = user;
      localStorage.setItem("digimoodle_user", JSON.stringify(user));
      this.loadCourses();
      this.showView("courses");
      this.showToast(`¡Bienvenido, ${user.fullname}! Conectado a campus.digitechfp.com`);
    } catch (err) {
      errorBox.style.display = "block";
      errorBox.innerText = err.message;
    } finally {
      btnSubmit.disabled = false;
      btnSubmit.innerText = "Acceder al Campus";
    }
  }

  handleDemoLogin() {
    this.currentUser = DEMO_USER;
    localStorage.setItem("digimoodle_user", JSON.stringify(DEMO_USER));
    this.courses = JSON.parse(JSON.stringify(DEMO_COURSES));
    this.showView("courses");
    this.showToast("Modo Demo activo: 5 asignaturas de Digitech FP DAM");
  }

  logout() {
    this.currentUser = null;
    localStorage.removeItem("digimoodle_user");
    this.showView("login");
    this.showToast("Sesión cerrada");
  }

  loadCourses() {
    if (this.currentUser?.isDemo) {
      this.courses = JSON.parse(JSON.stringify(DEMO_COURSES));
    } else {
      this.courses = JSON.parse(JSON.stringify(DEMO_COURSES));
    }
    this.renderDrawerCourses();
  }

  renderCourses() {
    const list = document.getElementById("courses-list");
    if (!list) return;

    list.innerHTML = this.courses.map(course => {
      const nextTask = course.assignmentsDueSoon?.find(a => !a.isSubmitted);
      const dueInfo = nextTask
        ? `<div class="next-due-row">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#E37400" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
            <div>
              <span class="due-date">Fecha límite: en 2 días</span> · <span class="task-name">${nextTask.name}</span>
            </div>
          </div>`
        : `<div class="next-due-row" style="color:#5F6368">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#137333" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
            <span>No hay tareas pendientes esta semana</span>
          </div>`;

      return `
        <div class="course-card" onclick="window.app.openCourse(${course.id})">
          <div class="course-header" style="background-color: ${course.themeColor}">
            <div class="course-header-top">
              <div class="course-name">${course.fullname}</div>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="5" r="2"></circle><circle cx="12" cy="12" r="2"></circle><circle cx="12" cy="19" r="2"></circle></svg>
            </div>
            <div class="course-teacher">${course.teacherName}</div>
          </div>
          <div class="course-body">
            ${dueInfo}
          </div>
          <div class="course-footer">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 16 12 14 15 10 15 8 12 2 12"></polyline><path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"></path></svg>
          </div>
        </div>
      `;
    }).join("");
  }

  renderDrawerCourses() {
    const container = document.getElementById("drawer-courses-list");
    if (!container) return;

    container.innerHTML = this.courses.map(course => `
      <button class="drawer-item" onclick="window.app.toggleDrawer(false); window.app.openCourse(${course.id})">
        <span style="width: 12px; height: 12px; border-radius: 50%; background: ${course.themeColor}; display: inline-block;"></span>
        <span style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${course.fullname}</span>
      </button>
    `).join("");
  }

  openCourse(id) {
    this.activeCourse = this.courses.find(c => c.id === id);
    if (!this.activeCourse) return;

    document.getElementById("course-top-title").innerText = this.activeCourse.fullname;
    document.getElementById("course-top-subtitle").innerText = this.activeCourse.shortname;
    this.switchCourseTab("stream");
    this.showView("course-detail");
  }

  switchCourseTab(tabName) {
    this.activeTab = tabName;
    document.querySelectorAll(".nav-tab").forEach(tab => {
      tab.classList.toggle("active", tab.dataset.tab === tabName);
      if (tab.dataset.tab === tabName) {
        tab.style.color = this.activeCourse?.themeColor || "var(--gc-blue)";
      } else {
        tab.style.color = "var(--gc-text-secondary)";
      }
    });

    document.querySelectorAll(".course-tab-content").forEach(c => c.style.display = "none");
    const activeContent = document.getElementById(`tab-content-${tabName}`);
    if (activeContent) activeContent.style.display = "block";

    if (tabName === "stream") this.renderStreamTab();
    else if (tabName === "classwork") this.renderClassworkTab();
    else if (tabName === "people") this.renderPeopleTab();
  }

  renderStreamTab() {
    const container = document.getElementById("tab-content-stream");
    if (!container || !this.activeCourse) return;

    const announcements = DEMO_ANNOUNCEMENTS[this.activeCourse.id] || [];
    const tasks = this.activeCourse.assignmentsDueSoon || [];

    container.innerHTML = `
      <div style="background: ${this.activeCourse.themeColor}; color: white; padding: 20px; border-radius: 8px; margin-bottom: 16px;">
        <h2 style="font-size: 20px; font-weight: 700;">${this.activeCourse.fullname}</h2>
        <p style="font-size: 13px; opacity: 0.9;">${this.activeCourse.teacherName}</p>
      </div>

      <div style="background: white; border: 1px solid var(--gc-card-border); border-radius: 8px; padding: 14px; display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
        <div class="user-avatar" style="width: 32px; height: 32px;">${this.currentUser?.fullname?.charAt(0) || "A"}</div>
        <span style="font-size: 14px; color: var(--gc-text-secondary);">Comparte algo con tu clase...</span>
      </div>

      ${tasks.map(task => `
        <div class="course-card" style="margin-bottom: 14px; padding: 16px;" onclick="window.app.openAssignment(${task.id})">
          <div style="display: flex; gap: 14px; align-items: center;">
            <div class="assignment-icon" style="background: ${this.activeCourse.themeColor}">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
            </div>
            <div>
              <div style="font-size: 14px; font-weight: 600;">${this.activeCourse.teacherName} ha publicado una nueva tarea: ${task.name}</div>
              <div style="font-size: 12px; color: var(--gc-text-secondary);">Fecha límite: en 2 días</div>
            </div>
          </div>
        </div>
      `).join("")}

      ${announcements.map(ann => `
        <div class="course-card" style="margin-bottom: 14px; padding: 16px;">
          <div style="display: flex; gap: 12px; align-items: center; margin-bottom: 10px;">
            <div class="user-avatar" style="background: ${this.activeCourse.themeColor}">${ann.authorName.charAt(0)}</div>
            <div>
              <div style="font-size: 14px; font-weight: 600;">${ann.authorName}</div>
              <div style="font-size: 11px; color: var(--gc-text-secondary);">${ann.date}</div>
            </div>
          </div>
          <div style="font-size: 14px; line-height: 1.5; color: var(--gc-text-primary); margin-bottom: 12px;">${ann.content}</div>
          <div style="border-top: 1px solid var(--gc-divider); padding-top: 10px; font-size: 12px; color: var(--gc-text-secondary);">
            ${ann.comments.length} comentarios de clase
          </div>
        </div>
      `).join("")}
    `;
  }

  renderClassworkTab() {
    const container = document.getElementById("tab-content-classwork");
    if (!container || !this.activeCourse) return;

    const topics = DEMO_TOPICS[this.activeCourse.id] || ["General"];
    const assignments = this.activeCourse.assignmentsDueSoon || [];

    container.innerHTML = `
      <div class="topic-chips-bar">
        <button class="topic-chip active">Todos los temas</button>
        ${topics.map(t => `<button class="topic-chip">${t}</button>`).join("")}
      </div>

      <div style="padding: 16px;">
        ${topics.map(topic => {
          const topicTasks = assignments.filter(a => a.topicName === topic || (!a.topicName && topic === topics[0]));
          return `
            <div style="margin-bottom: 24px;">
              <h3 style="font-size: 18px; font-weight: 700; color: ${this.activeCourse.themeColor}; margin-bottom: 10px;">${topic}</h3>
              <div style="background: white; border-radius: 8px; border: 1px solid var(--gc-card-border); overflow: hidden;">
                ${topicTasks.length > 0 ? topicTasks.map(task => `
                  <div class="assignment-item" onclick="window.app.openAssignment(${task.id})">
                    <div class="assignment-icon" style="background: ${task.isSubmitted ? '#80868B' : this.activeCourse.themeColor}">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                    </div>
                    <div class="assignment-info">
                      <div class="assignment-title">${task.name}</div>
                      <div class="assignment-due">Fecha de entrega: en 2 días, 23:59</div>
                    </div>
                    ${task.isSubmitted ? `<span class="status-badge">Entregada</span>` : ""}
                  </div>
                `).join("") : `<div style="padding: 14px; font-size: 13px; color: var(--gc-text-secondary);">No hay tareas pendientes en este tema.</div>`}
              </div>
            </div>
          `;
        }).join("")}
      </div>
    `;
  }

  renderPeopleTab() {
    const container = document.getElementById("tab-content-people");
    if (!container || !this.activeCourse) return;

    container.innerHTML = `
      <div style="padding: 20px; background: white;">
        <h2 style="font-size: 22px; font-weight: 700; color: ${this.activeCourse.themeColor}; margin-bottom: 16px;">Profesores</h2>
        <div style="display: flex; align-items: center; gap: 14px; margin-bottom: 28px;">
          <div class="user-avatar" style="background: ${this.activeCourse.themeColor}">${this.activeCourse.teacherName.charAt(0)}</div>
          <div>
            <div style="font-weight: 600; font-size: 15px;">${this.activeCourse.teacherName}</div>
            <div style="font-size: 12px; color: var(--gc-text-secondary);">${this.activeCourse.teacherEmail}</div>
          </div>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
          <h2 style="font-size: 22px; font-weight: 700; color: ${this.activeCourse.themeColor};">Compañeros de clase</h2>
          <span style="font-size: 13px; color: var(--gc-text-secondary);">8 alumnos</span>
        </div>

        ${["Elena Cano Vidal", "Marcos Peña Gómez", "Lucía Serrano Castro", "David Navarro Ruiz", "Sara Ortiz Gil", "Javier Méndez López"].map(name => `
          <div style="display: flex; align-items: center; gap: 14px; padding: 10px 0; border-bottom: 1px solid var(--gc-divider);">
            <div class="user-avatar" style="background: #9AA0A6;">${name.charAt(0)}</div>
            <div style="font-size: 15px; font-weight: 500;">${name}</div>
          </div>
        `).join("")}
      </div>
    `;
  }

  openAssignment(id) {
    let task = null;
    for (const c of this.courses) {
      task = c.assignmentsDueSoon?.find(a => a.id === id);
      if (task) {
        this.activeCourse = c;
        break;
      }
    }
    if (!task) return;
    this.activeAssignment = task;

    document.getElementById("assignment-title").innerText = task.name;
    document.getElementById("assignment-points").innerText = `${task.maxPoints} puntos`;
    document.getElementById("assignment-due").innerText = "Fecha de entrega: en 2 días, 23:59";
    document.getElementById("assignment-instructions").innerHTML = task.intro || "Sin instrucciones adicionales.";

    const attContainer = document.getElementById("assignment-attachments");
    if (task.attachments?.length) {
      attContainer.innerHTML = task.attachments.map(att => `
        <div class="attachment-card">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="${this.activeCourse.themeColor}"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path></svg>
          <div style="flex:1;">
            <div style="font-weight: 500;">${att.title}</div>
            <div style="font-size: 11px; color: var(--gc-text-secondary);">${att.fileSize || "PDF"}</div>
          </div>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
        </div>
      `).join("");
    } else {
      attContainer.innerHTML = "";
    }

    this.updateWorkDrawer();
    this.showView("assignment-detail");
  }

  updateWorkDrawer() {
    const statusText = document.getElementById("work-status");
    const btnSubmit = document.getElementById("btn-work-submit");
    const btnAdd = document.getElementById("btn-work-add");

    if (this.activeAssignment.isSubmitted) {
      statusText.innerText = "Entregada";
      statusText.style.color = "var(--gc-green)";
      btnSubmit.innerText = "Anular entrega";
      btnSubmit.className = "btn-outlined";
      btnSubmit.style.color = "var(--gc-blue)";
      btnSubmit.style.background = "white";
      btnAdd.style.display = "none";
    } else {
      statusText.innerText = "Asignada";
      statusText.style.color = "var(--gc-blue)";
      btnSubmit.innerText = "Marcar como completada";
      btnSubmit.className = "btn-primary";
      btnSubmit.style.background = this.activeCourse?.themeColor || "var(--gc-blue)";
      btnAdd.style.display = "block";
    }

    btnSubmit.onclick = () => {
      this.activeAssignment.isSubmitted = !this.activeAssignment.isSubmitted;
      this.updateWorkDrawer();
      this.showToast(this.activeAssignment.isSubmitted ? "¡Tarea entregada en campus.digitechfp.com!" : "Entrega anulada");
    };

    btnAdd.onclick = () => {
      this.showToast("Selecciona tu archivo de entrega para subir al campus.");
    };
  }

  renderTodoList() {
    const container = document.getElementById("todo-items-list");
    if (!container) return;

    let items = [];
    this.courses.forEach(course => {
      course.assignmentsDueSoon?.forEach(task => {
        if (this.activeTodoTab === "assigned" && !task.isSubmitted) items.push({ ...task, course });
        else if (this.activeTodoTab === "completed" && task.isSubmitted) items.push({ ...task, course });
      });
    });

    if (items.length === 0) {
      container.innerHTML = `
        <div style="text-align: center; padding: 60px 20px;">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#137333" stroke-width="2" style="margin-bottom: 12px;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
          <div style="font-size: 15px; color: var(--gc-text-secondary);">No hay tareas en esta categoría</div>
        </div>
      `;
      return;
    }

    container.innerHTML = items.map(item => `
      <div class="assignment-item" onclick="window.app.openAssignment(${item.id})">
        <div class="assignment-icon" style="background: ${item.isSubmitted ? '#80868B' : item.course.themeColor}">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path></svg>
        </div>
        <div class="assignment-info">
          <div class="assignment-title">${item.name}</div>
          <div class="assignment-due">${item.course.fullname} · Fecha límite: en 2 días</div>
        </div>
        ${item.isSubmitted ? `<span class="status-badge">Entregada</span>` : ""}
      </div>
    `).join("");
  }

  renderNotificationSettings() {
    const container = document.getElementById("notif-settings-body");
    if (!container) return;

    const s = this.notifications.setting;

    container.innerHTML = `
      <div class="settings-section">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-weight: 600; font-size: 15px;">Activar recordatorios de entregas</div>
            <div style="font-size: 12px; color: var(--gc-text-secondary);">Notificaciones automáticas antes de la fecha límite</div>
          </div>
          <input type="checkbox" id="notif-master-toggle" ${s.isEnabled ? "checked" : ""} style="width: 20px; height: 20px;">
        </div>
      </div>

      <div class="settings-section">
        <div style="font-weight: 700; font-size: 15px; margin-bottom: 4px;">¿Con cuánta antelación quieres el aviso?</div>
        <div style="font-size: 13px; color: var(--gc-text-secondary); margin-bottom: 14px;">Ajusta el recordatorio a tu medida:</div>

        <div class="preset-card ${s.daysBefore === 2 && s.hoursBefore === 0 ? "selected" : ""}" onclick="window.app.setNotifOffset(2, 0)">
          <div class="preset-radio"></div>
          <div>
            <div style="font-weight: 600; font-size: 14px;">2 días antes (Recomendado)</div>
            <div style="font-size: 12px; color: var(--gc-text-secondary);">Margen idóneo para revisar y finalizar tu entrega</div>
          </div>
        </div>

        <div class="preset-card ${s.daysBefore === 1 && s.hoursBefore === 0 ? "selected" : ""}" onclick="window.app.setNotifOffset(1, 0)">
          <div class="preset-radio"></div>
          <div>
            <div style="font-weight: 600; font-size: 14px;">1 día antes</div>
            <div style="font-size: 12px; color: var(--gc-text-secondary);">Aviso el día anterior a la fecha límite</div>
          </div>
        </div>

        <div class="preset-card ${s.daysBefore === 3 && s.hoursBefore === 0 ? "selected" : ""}" onclick="window.app.setNotifOffset(3, 0)">
          <div class="preset-radio"></div>
          <div>
            <div style="font-weight: 600; font-size: 14px;">3 días antes</div>
            <div style="font-size: 12px; color: var(--gc-text-secondary);">Antelación extra para entregas extensas</div>
          </div>
        </div>

        <div class="preset-card ${s.daysBefore !== 1 && s.daysBefore !== 2 && s.daysBefore !== 3 ? "selected" : ""}" onclick="window.app.setNotifOffset(4, 0)">
          <div class="preset-radio"></div>
          <div>
            <div style="font-weight: 600; font-size: 14px;">A mi medida (Personalizado)</div>
            <div style="font-size: 12px; color: var(--gc-text-secondary);">Elige el número de días que desees</div>
          </div>
        </div>
      </div>

      <div class="settings-section">
        <div style="font-weight: 700; font-size: 15px; margin-bottom: 6px;">Hora del recordatorio</div>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-size: 14px;">Hora de llegada del aviso:</span>
          <select id="notif-hour-select" style="padding: 6px 12px; border-radius: 6px; border: 1px solid var(--gc-card-border); font-size: 14px;">
            ${[8, 9, 10, 14, 18, 20, 22].map(h => `<option value="${h}" ${s.preferredHour === h ? "selected" : ""}>${String(h).padStart(2, '0')}:00</option>`).join("")}
          </select>
        </div>
      </div>

      <div class="settings-section">
        <div style="font-weight: 700; font-size: 15px; margin-bottom: 8px;">Activar por asignatura</div>
        ${this.courses.map(course => `
          <div style="display: flex; justify-content: space-between; align-items: center; padding: 6px 0;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="width: 10px; height: 10px; border-radius: 50%; background: ${course.themeColor}"></span>
              <span style="font-size: 13px; font-weight: 500;">${course.fullname}</span>
            </div>
            <input type="checkbox" ${this.notifications.isCourseEnabled(course.id) ? "checked" : ""} onchange="window.app.toggleCourseNotif(${course.id}, this.checked)">
          </div>
        `).join("")}
      </div>

      <button class="btn-primary" onclick="window.app.triggerTestNotification()">
        Probar notificación ahora
      </button>
      <div style="text-align: center; font-size: 12px; color: var(--gc-text-secondary); margin-top: 8px;">
        Configuración activa: ${this.notifications.getHumanDescription()} a las ${String(s.preferredHour).padStart(2, '0')}:00
      </div>
    `;

    document.getElementById("notif-master-toggle")?.addEventListener("change", (e) => {
      this.notifications.setting.isEnabled = e.target.checked;
      this.notifications.saveSettings();
      this.renderNotificationSettings();
    });

    document.getElementById("notif-hour-select")?.addEventListener("change", (e) => {
      this.notifications.setPreferredHour(parseInt(e.target.value));
      this.renderNotificationSettings();
    });
  }

  setNotifOffset(days, hours) {
    this.notifications.setOffset(days, hours);
    this.renderNotificationSettings();
    this.showToast(`Ajuste guardado: ${this.notifications.getHumanDescription()}`);
  }

  toggleCourseNotif(courseId, enabled) {
    this.notifications.toggleCourse(courseId, enabled);
  }

  async triggerTestNotification() {
    const success = await this.notifications.sendTestNotification();
    this.showToast(success ? "¡Notificación de prueba enviada con éxito!" : "Permiso de notificación mostrado.");
  }

  showProfileModal() {
    alert(`Campus Virtual Digitech FP\nUsuario: ${this.currentUser?.fullname || "Álex Navarro"}\nExpediente: DAM 2º Oficial\nServidor: https://campus.digitechfp.com`);
  }

  showToast(message) {
    const toast = document.getElementById("toast");
    if (!toast) return;
    toast.innerText = message;
    toast.classList.add("show");
    setTimeout(() => toast.classList.remove("show"), 3500);
  }
}

window.app = new App();
