<template>
  <div id="dispatcher-app">
    <header class="navbar">
      <h1>HVAC Dispatcher Web Portal</h1>
      <div v-if="isAuthenticated" class="user-info">
        <span>Welcome, {{ username }}</span>
        <button @click="logout" class="btn-logout">Logout</button>
      </div>
    </header>

    <main class="container">
      <!-- Login Section -->
      <div v-if="!isAuthenticated" class="login-card">
        <h2>Odoo Authentication</h2>
        <form @submit.prevent="login">
          <div class="form-group">
            <label>Odoo URL (Proxy Target Defaults to Localhost)</label>
            <input type="text" v-model="odooUrl" disabled />
          </div>
          <div class="form-group">
            <label>Database</label>
            <input type="text" v-model="db" required />
          </div>
          <div class="form-group">
            <label>Username / Email</label>
            <input type="text" v-model="loginEmail" required />
          </div>
          <div class="form-group">
            <label>Password</label>
            <input type="password" v-model="password" required />
          </div>
          <button type="submit" :disabled="loading" class="btn-primary">
            {{ loading ? 'Logging in...' : 'Login' }}
          </button>
          <p v-if="error" class="error-text">{{ error }}</p>
        </form>
      </div>

      <!-- Main Dashboard Schedule Section -->
      <div v-else class="dashboard">
        <section class="scheduling-container">
          <div class="left-panel">
            <h3>Unassigned Service Orders</h3>
            <div 
              class="draggable-list"
              @dragover.prevent
              @drop="onDropToUnassigned"
            >
              <div 
                v-for="order in unassignedOrders" 
                :key="order.id" 
                class="order-item"
                draggable="true"
                @dragstart="onDragStart($event, order)"
              >
                <strong>{{ order.name }}</strong>
                <p>{{ order.address }}</p>
                <!-- Keyboard accessibility controls -->
                <div class="keyboard-assign">
                  <select 
                    v-model="selectedTechs[order.id]" 
                    :aria-label="'Select technician for ' + order.name"
                  >
                    <option value="">Assign to...</option>
                    <option v-for="tech in technicians" :key="tech.id" :value="tech.id">
                      {{ tech.name }}
                    </option>
                  </select>
                  <button 
                    @click="keyboardAssign(order)" 
                    :disabled="!selectedTechs[order.id]"
                    class="btn-keyboard-assign"
                  >
                    Assign
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="center-panel">
            <h3>Dispatcher Schedule Timeline</h3>
            <div class="timeline-grid">
              <div class="technician-row" v-for="tech in technicians" :key="tech.id">
                <div class="tech-info">
                  <strong>{{ tech.name }}</strong>
                  <span>📍 {{ tech.last_gps || 'No GPS' }}</span>
                </div>
                <div 
                  class="tech-timeline"
                  @dragover.prevent
                  @drop="onDropToTechnician($event, tech.id)"
                >
                  <div 
                    v-for="order in getOrdersForTech(tech.id)" 
                    :key="order.id"
                    class="order-block"
                    draggable="true"
                    @dragstart="onDragStart($event, order)"
                  >
                    <span>{{ order.name }}</span>
                    <small style="display:block; font-size:10px; opacity:0.8;">{{ order.address }}</small>
                    <!-- Keyboard-accessible unassign control -->
                    <button 
                      class="btn-keyboard-unassign" 
                      @click="keyboardUnassign(order)" 
                      title="Unassign Order"
                      :aria-label="'Unassign order ' + order.name"
                    >
                      ✕
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </main>
  </div>
</template>

<script>
export default {
  data() {
    return {
      isAuthenticated: false,
      username: '',
      csrfToken: '',
      odooUrl: 'http://localhost:8069 (via Vite Proxy)',
      db: 'fieldforce',
      loginEmail: '',
      password: '',
      loading: false,
      error: '',
      unassignedOrders: [],
      technicians: [],
      assignedOrders: [],
      draggedOrder: null,
      selectedTechs: {}
    };
  },
  methods: {
    async login() {
      this.loading = true;
      this.error = '';
      try {
        const payload = {
          jsonrpc: '2.0',
          method: 'call',
          params: {
            db: this.db,
            login: this.loginEmail,
            password: this.password
          }
        };

        const res = await fetch('/web/session/authenticate', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'include',
          body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if (data.result && data.result.uid) {
          this.isAuthenticated = true;
          this.username = data.result.name;
          await this.getCsrfToken();
          await this.fetchData();
        } else if (data.error) {
          this.error = data.error.data.message || 'Authentication failed.';
        } else {
          this.error = 'Invalid credentials or database.';
        }
      } catch (err) {
        this.error = 'Failed to connect to proxy server. Ensure Odoo is running.';
      } finally {
        this.loading = false;
      }
    },
    async getCsrfToken() {
      try {
        const res = await fetch('/web/session/get_session_info', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'include',
          body: JSON.stringify({ jsonrpc: '2.0', method: 'call', params: {} })
        });
        const data = await res.json();
        if (data.result && data.result.csrf_token) {
          this.csrfToken = data.result.csrf_token;
        }
      } catch (err) {
        console.error('Failed to get CSRF token', err);
      }
    },
    async fetchData() {
      this.loading = true;
      try {
        const devs = await this.callRPC('fsm.person', 'search_read', [[]], {
          fields: ['id', 'display_name', 'partner_id']
        });
        this.technicians = devs.map(t => ({
          id: t.id,
          name: t.display_name || (t.partner_id ? t.partner_id[1] : `Technician #${t.id}`),
          last_gps: 'Connected'
        }));

        const unassigned = await this.callRPC('fsm.order', 'search_read', [[['person_id', '=', false]]], {
          fields: ['id', 'name', 'location_id']
        });
        this.unassignedOrders = unassigned.map(o => ({
          id: o.id,
          name: o.name,
          address: o.location_id ? o.location_id[1] : 'No Address'
        }));

        const assigned = await this.callRPC('fsm.order', 'search_read', [[['person_id', '!=', false]]], {
          fields: ['id', 'name', 'location_id', 'person_id']
        });
        this.assignedOrders = assigned.map(o => ({
          id: o.id,
          name: o.name,
          address: o.location_id ? o.location_id[1] : 'No Address',
          technicianId: o.person_id[0]
        }));
      } catch (err) {
        console.error('Error fetching data from Odoo:', err);
        this.error = 'Failed to retrieve records: ' + err.message;
      } finally {
        this.loading = false;
      }
    },
    async callRPC(model, method, args = [], kwargs = {}) {
      const payload = {
        jsonrpc: '2.0',
        method: 'call',
        params: {
          model,
          method,
          args,
          kwargs,
          csrf_token: this.csrfToken
        }
      };
      const headers = { 'Content-Type': 'application/json' };
      if (this.csrfToken) {
        headers['X-Openerp-Csrf-Token'] = this.csrfToken;
      }
      const res = await fetch('/web/dataset/call_kw', {
        method: 'POST',
        headers,
        credentials: 'include',
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (data.error) {
        throw new Error(data.error.data.message || data.error.message);
      }
      return data.result;
    },
    logout() {
      this.isAuthenticated = false;
      this.username = '';
      this.csrfToken = '';
      this.loginEmail = '';
      this.password = '';
      this.unassignedOrders = [];
      this.technicians = [];
      this.assignedOrders = [];
    },
    onDragStart(event, order) {
      this.draggedOrder = order;
      event.dataTransfer.effectAllowed = 'move';
    },
    async assignOrderToTech(order, techId) {
      try {
        this.loading = true;
        await this.callRPC('fsm.order', 'write', [[order.id], { person_id: techId }]);
        if (order.technicianId !== undefined) {
          const activeOrder = this.assignedOrders.find(o => o.id === order.id);
          if (activeOrder) {
            activeOrder.technicianId = techId;
          }
        } else {
          this.unassignedOrders = this.unassignedOrders.filter(o => o.id !== order.id);
          this.assignedOrders.push({ ...order, technicianId: techId });
        }
      } catch (err) {
        alert('Failed to save assignment in Odoo: ' + err.message);
      } finally {
        this.loading = false;
      }
    },
    async unassignOrder(order) {
      try {
        this.loading = true;
        await this.callRPC('fsm.order', 'write', [[order.id], { person_id: false }]);
        this.assignedOrders = this.assignedOrders.filter(o => o.id !== order.id);
        const { technicianId, ...unassignedOrder } = order;
        this.unassignedOrders.push(unassignedOrder);
      } catch (err) {
        alert('Failed to clear assignment in Odoo: ' + err.message);
      } finally {
        this.loading = false;
      }
    },
    async onDropToTechnician(event, techId) {
      if (!this.draggedOrder) return;
      const order = this.draggedOrder;
      this.draggedOrder = null;
      await this.assignOrderToTech(order, techId);
    },
    async onDropToUnassigned() {
      if (!this.draggedOrder) return;
      const order = this.draggedOrder;
      this.draggedOrder = null;
      if (order.technicianId === undefined) return;
      await this.unassignOrder(order);
    },
    async keyboardAssign(order) {
      const techId = this.selectedTechs[order.id];
      if (!techId) return;
      await this.assignOrderToTech(order, techId);
      delete this.selectedTechs[order.id];
    },
    async keyboardUnassign(order) {
      await this.unassignOrder(order);
    },
    getOrdersForTech(techId) {
      return this.assignedOrders.filter(o => o.technicianId === techId);
    }
  }
};
</script>

<style scoped>
#dispatcher-app {
  font-family: Arial, sans-serif;
  color: #333;
  margin: 0;
  padding: 0;
}
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #2c3e50;
  color: white;
  padding: 10px 20px;
}
.navbar h1 {
  margin: 0;
  font-size: 20px;
}
.btn-logout {
  background-color: #e74c3c;
  color: white;
  border: none;
  padding: 6px 12px;
  cursor: pointer;
  margin-left: 10px;
  border-radius: 4px;
}
.container {
  padding: 20px;
}
.login-card {
  max-width: 400px;
  margin: 40px auto;
  padding: 20px;
  border: 1px solid #ccc;
  border-radius: 8px;
  background-color: #f9f9f9;
}
.form-group {
  margin-bottom: 15px;
}
.form-group label {
  display: block;
  font-weight: bold;
  margin-bottom: 5px;
}
.form-group input {
  width: 100%;
  padding: 8px;
  box-sizing: border-box;
  border-radius: 4px;
  border: 1px solid #ccc;
}
.btn-primary {
  background-color: #3498db;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  width: 100%;
}
.error-text {
  color: #e74c3c;
  margin-top: 10px;
}
.scheduling-container {
  display: flex;
  gap: 20px;
}
.left-panel {
  width: 250px;
  border: 1px solid #ddd;
  padding: 10px;
  border-radius: 6px;
  background-color: #fcfcfc;
}
.draggable-list {
  min-height: 200px;
  border: 2px dashed #ccc;
  border-radius: 4px;
  padding: 10px;
}
.order-item {
  background-color: #ecf0f1;
  padding: 10px;
  margin-bottom: 10px;
  border-radius: 4px;
  cursor: grab;
  border: 1px solid #bdc3c7;
}
.center-panel {
  flex-grow: 1;
  border: 1px solid #ddd;
  padding: 10px;
  border-radius: 6px;
}
.timeline-grid {
  display: flex;
  flex-direction: column;
  gap: 15px;
}
.technician-row {
  display: flex;
  border: 1px solid #eee;
  border-radius: 4px;
  overflow: hidden;
}
.tech-info {
  width: 200px;
  background-color: #f5f5f5;
  padding: 10px;
  border-right: 1px solid #eee;
  display: flex;
  flex-direction: column;
}
.tech-timeline {
  flex-grow: 1;
  min-height: 80px;
  background-color: #fafafa;
  padding: 10px;
  display: flex;
  gap: 10px;
  align-items: center;
}
.order-block {
  background-color: #2ecc71;
  color: white;
  padding: 10px;
  border-radius: 4px;
  font-size: 14px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  display: flex;
  align-items: center;
  gap: 8px;
}
.keyboard-assign {
  margin-top: 10px;
  display: flex;
  gap: 5px;
  flex-direction: column;
}
.keyboard-assign select {
  font-size: 12px;
  padding: 4px;
  border-radius: 4px;
  border: 1px solid #ccc;
}
.btn-keyboard-assign {
  background-color: #3498db;
  color: white;
  border: none;
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
}
.btn-keyboard-assign:disabled {
  background-color: #bdc3c7;
  cursor: not-allowed;
}
.btn-keyboard-unassign {
  background-color: transparent;
  color: white;
  border: none;
  font-weight: bold;
  cursor: pointer;
  padding: 2px 6px;
  border-radius: 50%;
  transition: background-color 0.2s;
}
.btn-keyboard-unassign:hover {
  background-color: rgba(255, 255, 255, 0.2);
}
</style>