const STORAGE_KEY = 'goat-management-system-records';

const demoData = [
  {
    id: 1,
    goatNumber: 'G-001',
    owner: 'Nairobi Farm',
    dob: '2022-05-15',
    vaccinationDate: '2025-10-08',
    numberOfGoats: 18,
    vaccineType: 'Multivitamin Booster'
  },
  {
    id: 2,
    goatNumber: 'G-024',
    owner: 'Green Valley',
    dob: '2023-02-09',
    vaccinationDate: '2025-10-15',
    numberOfGoats: 26,
    vaccineType: 'Foot and Mouth Prevention'
  },
  {
    id: 3,
    goatNumber: 'G-042',
    owner: 'Hilltop Ranch',
    dob: '2021-11-27',
    vaccinationDate: '2025-09-30',
    numberOfGoats: 12,
    vaccineType: 'Pneumonia Vaccine'
  }
];

const form = document.getElementById('goatForm');
const formTitle = document.getElementById('formTitle');
const submitBtn = document.getElementById('submitBtn');
const cancelEditBtn = document.getElementById('cancelEditBtn');
const goatTableBody = document.getElementById('goatTableBody');
const searchInput = document.getElementById('searchInput');
const resetDataBtn = document.getElementById('resetDataBtn');

const fields = {
  goatNumber: document.getElementById('goatNumber'),
  owner: document.getElementById('owner'),
  dob: document.getElementById('dob'),
  vaccinationDate: document.getElementById('vaccinationDate'),
  numberOfGoats: document.getElementById('numberOfGoats'),
  vaccineType: document.getElementById('vaccineType')
};

let records = loadRecords();
let editingId = null;

function loadRecords() {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (saved) {
    try {
      const parsed = JSON.parse(saved);
      if (Array.isArray(parsed) && parsed.length) {
        return parsed;
      }
    } catch (error) {
      console.error('Could not parse saved records.', error);
    }
  }

  localStorage.setItem(STORAGE_KEY, JSON.stringify(demoData));
  return [...demoData];
}

function saveRecords() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
}

function formatDate(dateString) {
  if (!dateString) return '—';
  const date = new Date(dateString);
  if (Number.isNaN(date.getTime())) return '—';
  return new Intl.DateTimeFormat('en-GB', {
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  }).format(date);
}

function calculateTotals() {
  const totalGoats = records.length;
  const vaccinated = records.filter((record) => record.vaccinationDate).length;
  const herdCount = records.reduce((sum, record) => sum + Number(record.numberOfGoats || 0), 0);
  const owners = new Set(records.map((record) => record.owner.trim().toLowerCase()).filter(Boolean)).size;

  document.getElementById('totalGoatsStat').textContent = totalGoats;
  document.getElementById('vaccinatedStat').textContent = vaccinated;
  document.getElementById('herdCountStat').textContent = herdCount;
  document.getElementById('ownerCountStat').textContent = owners;
}

function renderTable() {
  const query = searchInput.value.trim().toLowerCase();
  const filteredRecords = query
    ? records.filter((record) => {
        return Object.values(record)
          .filter((value) => typeof value === 'string' || typeof value === 'number')
          .join(' ')
          .toLowerCase()
          .includes(query);
      })
    : records;

  if (!filteredRecords.length) {
    goatTableBody.innerHTML = document.getElementById('emptyStateTemplate').innerHTML;
    calculateTotals();
    return;
  }

  goatTableBody.innerHTML = filteredRecords
    .map(
      (record) => `
        <tr>
          <td><strong>${record.goatNumber}</strong></td>
          <td>${record.owner}</td>
          <td>${formatDate(record.dob)}</td>
          <td>
            <span class="badge">${formatDate(record.vaccinationDate)}</span>
          </td>
          <td>${record.numberOfGoats}</td>
          <td>
            <div class="action-group">
              <button class="action-button edit" type="button" data-action="edit" data-id="${record.id}">Edit</button>
              <button class="action-button delete" type="button" data-action="delete" data-id="${record.id}">Delete</button>
            </div>
          </td>
        </tr>
      `
    )
    .join('');

  calculateTotals();
}

function resetForm() {
  form.reset();
  editingId = null;
  formTitle.textContent = 'Add Goat Record';
  submitBtn.textContent = 'Save Record';
  cancelEditBtn.classList.add('hidden');
}

function populateForm(record) {
  fields.goatNumber.value = record.goatNumber;
  fields.owner.value = record.owner;
  fields.dob.value = record.dob;
  fields.vaccinationDate.value = record.vaccinationDate;
  fields.numberOfGoats.value = record.numberOfGoats;
  fields.vaccineType.value = record.vaccineType || '';

  editingId = record.id;
  formTitle.textContent = 'Edit Goat Record';
  submitBtn.textContent = 'Update Record';
  cancelEditBtn.classList.remove('hidden');
}

form.addEventListener('submit', (event) => {
  event.preventDefault();

  const goatNumber = fields.goatNumber.value.trim();
  const owner = fields.owner.value.trim();
  const dob = fields.dob.value;
  const vaccinationDate = fields.vaccinationDate.value;
  const numberOfGoats = Number(fields.numberOfGoats.value);
  const vaccineType = fields.vaccineType.value.trim();

  if (!goatNumber || !owner || !dob || !vaccinationDate || !numberOfGoats) {
    alert('Please complete all required fields before saving.');
    return;
  }

  const newRecord = {
    id: editingId ?? Date.now(),
    goatNumber,
    owner,
    dob,
    vaccinationDate,
    numberOfGoats,
    vaccineType
  };

  if (editingId) {
    records = records.map((record) => (record.id === editingId ? newRecord : record));
  } else {
    records.unshift(newRecord);
  }

  saveRecords();
  renderTable();
  resetForm();
});

goatTableBody.addEventListener('click', (event) => {
  const button = event.target.closest('button');
  if (!button) return;

  const id = Number(button.dataset.id);
  const action = button.dataset.action;

  if (action === 'edit') {
    const record = records.find((item) => item.id === id);
    if (record) populateForm(record);
  }

  if (action === 'delete') {
    const shouldDelete = window.confirm('Delete this goat record?');
    if (!shouldDelete) return;

    records = records.filter((record) => record.id !== id);
    saveRecords();
    renderTable();

    if (editingId === id) {
      resetForm();
    }
  }
});

cancelEditBtn.addEventListener('click', () => {
  resetForm();
});

searchInput.addEventListener('input', renderTable);

resetDataBtn.addEventListener('click', () => {
  const shouldReset = window.confirm('Reset the goat records to the demo data?');
  if (!shouldReset) return;

  records = [...demoData];
  saveRecords();
  renderTable();
  resetForm();
});

renderTable();
resetForm();
