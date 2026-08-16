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
                  >
                    <span>{{ order.name }}</span>
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
      odooUrl: 'http://localhost:8069 (via Vite Proxy)',
      db: 'fieldforce',
      loginEmail: '',
      password: '',
      loading: false,
      error: '',
      unassignedOrders: [
        { id: 1, name: 'Aircon Cleaning #1042', address: '123 Main St' },
        { id: 2, name: 'Compressor Repair #1043', address: '456 Elm St' }
      ],
      technicians: [
        { id: 101, name: 'Nguyen Van A (Tech 1)', last_gps: '10.776, 106.701 (District 1)' },
        { id: 102, name: 'Tran Van B (Tech 2)', last_gps: '10.802, 106.664 (Tan Binh)' }
      ],
      assignedOrders: [],
      draggedOrder: null
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
          body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if (data.result && data.result.uid) {
          this.isAuthenticated = true;
          this.username = data.result.name;
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
    logout() {
      this.isAuthenticated = false;
      this.username = '';
      this.loginEmail = '';
      this.password = '';
    },
    onDragStart(event, order) {
      this.draggedOrder = order;
      event.dataTransfer.effectAllowed = 'move';
    },
    onDropToTechnician(event, techId) {
      if (!this.draggedOrder) return;
      // Remove from unassigned, add to assigned
      this.unassignedOrders = this.unassignedOrders.filter(o => o.id !== this.draggedOrder.id);
      
      const newAssigned = { ...this.draggedOrder, technicianId: techId };
      this.assignedOrders.push(newAssigned);
      this.draggedOrder = null;
    },
    onDropToUnassigned() {
      // Logic to revert assignment can also be implemented
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
}
</style>