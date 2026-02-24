// ═══════════════════════════════════════
//  e_vehiclesrent – NUI
// ═══════════════════════════════════════

const RES = (() => {
    try { return window.GetParentResourceName(); }
    catch (_) { return 'e_vehiclesrent'; }
})();

let vehicles = [];
let selectedVehicle = null;
let activeTimers = [];
let timerInterval = null;
let locale = {};

// ── Message handler ──

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'open') {
        vehicles = data.vehicles || [];
        locale = data.locale || {};

        // Apply locale to static UI elements
        document.getElementById('panel-title').textContent = data.title || locale.title || '';
        document.getElementById('lbl-duration').textContent = locale.duration || 'Duration';
        document.getElementById('lbl-total').textContent = (locale.total || 'Total') + ':';
        document.getElementById('btn-cancel').textContent = locale.cancel || 'Cancel';
        document.getElementById('btn-confirm').textContent = locale.confirm || 'Rent';

        renderVehicles();
        deselectVehicle();
        document.getElementById('container').style.display = 'flex';
    }

    if (data.action === 'close') {
        document.getElementById('container').style.display = 'none';
        selectedVehicle = null;
    }

    if (data.action === 'addTimer') {
        addTimer(data.seconds, data.model);
    }

    if (data.action === 'removeTimer') {
        removeOldestTimer();
    }
});

// ══════════════════════════════════════
//  VEHICLE GRID
// ══════════════════════════════════════

function renderVehicles() {
    const grid = document.getElementById('vehicle-grid');
    grid.innerHTML = '';

    vehicles.forEach((v, idx) => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';
        card.dataset.index = idx;
        card.onclick = () => selectVehicle(idx);

        // Optional image
        if (v.image) {
            const img = document.createElement('img');
            img.className = 'v-image';
            img.src = 'img/' + v.image;
            img.alt = v.label;
            card.appendChild(img);
        }

        const info = document.createElement('div');
        info.className = 'v-info';

        const name = document.createElement('span');
        name.className = 'v-name';
        name.textContent = v.label;

        const price = document.createElement('span');
        price.className = 'v-price' + (v.price <= 0 ? ' free' : '');
        price.textContent = v.price <= 0
            ? (locale.free || 'Free')
            : '$' + v.price + (locale.perUnit || '/10min');

        info.appendChild(name);
        info.appendChild(price);
        card.appendChild(info);
        grid.appendChild(card);
    });
}

function selectVehicle(idx) {
    selectedVehicle = vehicles[idx];

    document.querySelectorAll('.vehicle-card').forEach((c, i) => {
        c.classList.toggle('selected', i === idx);
    });

    document.getElementById('rent-config').classList.remove('hidden');
    document.getElementById('selected-name').textContent = selectedVehicle.label;
    document.getElementById('selected-price').textContent =
        selectedVehicle.price <= 0
            ? (locale.free || 'Free')
            : '$' + selectedVehicle.price + ' ' + (locale.perUnit || '/10min');

    document.getElementById('duration-slider').value = 1;
    updateTotal();
}

function deselectVehicle() {
    selectedVehicle = null;
    document.querySelectorAll('.vehicle-card').forEach(c => c.classList.remove('selected'));
    document.getElementById('rent-config').classList.add('hidden');
}

function updateTotal() {
    const slider = document.getElementById('duration-slider');
    const duration = parseInt(slider.value);
    const minutes = duration * 10;
    const minLabel = locale.minutes || 'min';

    if (minutes >= 60) {
        const hours = Math.floor(minutes / 60);
        const mins = minutes % 60;
        document.getElementById('duration-text').textContent =
            hours + 'h' + (mins > 0 ? ' ' + mins + minLabel : '');
    } else {
        document.getElementById('duration-text').textContent = minutes + ' ' + minLabel;
    }

    if (selectedVehicle) {
        const total = selectedVehicle.price * duration;
        document.getElementById('total-price').textContent =
            total <= 0 ? (locale.free || 'Free') : '$' + total;
    }
}

function confirmRent() {
    if (!selectedVehicle) return;

    const duration = parseInt(document.getElementById('duration-slider').value);

    fetch(`https://${RES}/rent`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            model: selectedVehicle.model,
            duration: duration
        })
    });
}

function closeMenu() {
    fetch(`https://${RES}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeMenu();
});

// ══════════════════════════════════════
//  TIMER HUD
// ══════════════════════════════════════

function addTimer(seconds, model) {
    activeTimers.push({ endTime: Date.now() + (seconds * 1000), model });
    renderTimers();
    startTimerTick();
}

function removeOldestTimer() {
    if (activeTimers.length > 0) {
        activeTimers.shift();
        renderTimers();
    }
    if (activeTimers.length === 0) stopTimerTick();
}

function renderTimers() {
    const hud = document.getElementById('timer-hud');
    hud.innerHTML = '';

    activeTimers.forEach((timer, idx) => {
        const remaining = Math.max(0, Math.floor((timer.endTime - Date.now()) / 1000));
        const isWarning = remaining < 120;

        const item = document.createElement('div');
        item.className = 'timer-item' + (isWarning ? ' warning' : '');
        item.dataset.index = idx;

        item.innerHTML = `
            <div class="timer-dot"></div>
            <div class="timer-info">
                <span class="timer-model">${timer.model}</span>
                <span class="timer-countdown">${formatTime(remaining)}</span>
            </div>
        `;

        hud.appendChild(item);
    });
}

function formatTime(totalSeconds) {
    const h = Math.floor(totalSeconds / 3600);
    const m = Math.floor((totalSeconds % 3600) / 60);
    const s = totalSeconds % 60;
    const pad = (n) => n.toString().padStart(2, '0');

    return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${pad(m)}:${pad(s)}`;
}

function tickTimers() {
    const items = document.querySelectorAll('#timer-hud .timer-item');

    activeTimers.forEach((timer, idx) => {
        const remaining = Math.max(0, Math.floor((timer.endTime - Date.now()) / 1000));
        const item = items[idx];
        if (item) {
            item.querySelector('.timer-countdown').textContent = formatTime(remaining);
            item.classList.toggle('warning', remaining < 120);
        }
    });
}

function startTimerTick() {
    if (timerInterval) return;
    timerInterval = setInterval(tickTimers, 1000);
}

function stopTimerTick() {
    if (timerInterval) {
        clearInterval(timerInterval);
        timerInterval = null;
    }
    document.getElementById('timer-hud').innerHTML = '';
}
