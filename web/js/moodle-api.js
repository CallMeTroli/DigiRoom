// Client for https://campus.digitechfp.com Moodle Web Services API

export class MoodleAPI {
  constructor(baseUrl = "https://campus.digitechfp.com") {
    this.baseUrl = baseUrl;
  }

  async login(username, password) {
    const url = `${this.baseUrl}/login/token.php`;
    const params = new URLSearchParams({
      username: username.trim(),
      password: password.trim(),
      service: "moodle_mobile_app"
    });

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: params.toString()
      });

      const data = await response.json();

      if (data.error) {
        throw new Error(data.error);
      }

      if (!data.token) {
        throw new Error("No se pudo obtener el token de acceso móvil del campus.");
      }

      // Fetch user info with token
      const siteInfo = await this.getSiteInfo(data.token);

      return {
        id: siteInfo.userid || 1,
        username: siteInfo.username || username,
        fullname: siteInfo.fullname || username,
        firstname: siteInfo.firstname || username,
        lastname: siteInfo.lastname || "",
        siteurl: this.baseUrl,
        token: data.token,
        isDemo: false
      };
    } catch (err) {
      // In browser environments without CORS headers, fallback message or proxy notice
      if (err.message.includes("Failed to fetch") || err.name === "TypeError") {
        throw new Error("El navegador bloqueó la petición directa por CORS. En la app iOS nativa se conecta directamente sin restricciones. Puedes usar el 'Modo Demo' para explorar todas las funciones en el navegador.");
      }
      throw err;
    }
  }

  async getSiteInfo(token) {
    return this.callService("core_webservice_get_site_info", token, {});
  }

  async getEnrolledCourses(token, userId) {
    const data = await this.callService("core_enrol_get_users_courses", token, { userid: userId });
    return data;
  }

  async getAssignments(token, courseIds) {
    const params = {};
    courseIds.forEach((id, i) => {
      params[`courseids[${i}]`] = id;
    });
    return this.callService("mod_assign_get_assignments", token, params);
  }

  async callService(wsfunction, token, params = {}) {
    const url = `${this.baseUrl}/webservice/rest/server.php`;
    const formParams = new URLSearchParams({
      wstoken: token,
      wsfunction: wsfunction,
      moodlewsrestformat: "json",
      ...params
    });

    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: formParams.toString()
    });

    const data = await response.json();
    if (data.exception) {
      throw new Error(data.message || data.exception);
    }
    return data;
  }
}
