// ===== REFERENCIAS =====
const cuerpoTabla = document.getElementById('cuerpo-tabla')
const totalProductos = document.getElementById('total-productos')
const stockTotal = document.getElementById('stock-total')
const totalVendido = document.getElementById('total-vendido')
const filtroCategoria = document.getElementById('filtro-categoria')

// ===== VARIABLES =====
let datosGlobal = []
let graficoBarras
let graficoTorta

// ===== FORMATO MONEDA =====
function formatear(numero) {
  return new Intl.NumberFormat('es-PE', {
    style: 'currency',
    currency: 'PEN',
  }).format(numero)
}

// ===== MOSTRAR DATOS =====
function mostrarDatos(datos) {
  cuerpoTabla.innerHTML = ''

  let stock = 0
  let vendido = 0

  // 🔥 encontrar el máximo vendido
  const maxVendido = Math.max(...datos.map((d) => d.vendido))

  datos.forEach((item) => {
    const fila = document.createElement('tr')

    // ✅ resaltar producto más vendido
    if (item.vendido === maxVendido && maxVendido > 0) {
      fila.classList.add('destacado')
    }

    fila.innerHTML = `
      <td>${item.producto}</td>
      <td>${item.categoria}</td>
      <td>${formatear(item.precio)}</td>
      <td class="${item.stock < 50 ? 'bajo-stock' : ''}">
        ${item.stock}
      </td>
      <td>${item.vendido}</td>
    `

    cuerpoTabla.appendChild(fila)

    stock += item.stock
    vendido += item.vendido
  })

  totalProductos.textContent = datos.length
  stockTotal.textContent = stock
  totalVendido.textContent = vendido
}

// ===== LLENAR CATEGORIAS =====
function llenarCategorias(datos) {
  const categorias = [...new Set(datos.map((d) => d.categoria))]

  categorias.forEach((cat) => {
    const option = document.createElement('option')
    option.value = cat
    option.textContent = cat
    filtroCategoria.appendChild(option)
  })
}

// ===== FILTRAR =====
function aplicarFiltro() {
  const categoria = filtroCategoria.value

  let filtrados = datosGlobal

  if (categoria !== '') {
    filtrados = filtrados.filter((d) => d.categoria === categoria)
  }

  mostrarDatos(filtrados)
  crearGraficos(filtrados)
}

filtroCategoria.addEventListener('change', aplicarFiltro)

// ===== GRAFICOS =====
function crearGraficos(datos) {
  // ===== BARRAS =====
  let nombres = datos.map((d) => d.producto)
  let vendidos = datos.map((d) => d.vendido)

  if (graficoBarras) graficoBarras.destroy()

  const ctx1 = document.getElementById('graficoVentas').getContext('2d')

  graficoBarras = new Chart(ctx1, {
    type: 'bar',
    data: {
      labels: nombres,
      datasets: [
        {
          label: 'Productos vendidos',
          data: vendidos,
          backgroundColor: '#3498db',
        },
      ],
    },
  })

  // ===== TORTA =====
  const categorias = {}

  datos.forEach((d) => {
    if (!categorias[d.categoria]) {
      categorias[d.categoria] = 0
    }
    categorias[d.categoria] += d.vendido
  })

  if (graficoTorta) graficoTorta.destroy()

  const ctx2 = document.getElementById('graficoCategorias').getContext('2d')

  graficoTorta = new Chart(ctx2, {
    type: 'pie',
    data: {
      labels: Object.keys(categorias),
      datasets: [
        {
          data: Object.values(categorias),
          backgroundColor: [
            '#3498db',
            '#2ecc71',
            '#e74c3c',
            '#f1c40f',
            '#9b59b6',
          ],
        },
      ],
    },
  })
}

// ===== FETCH =====
fetch('./data.json')
  .then((res) => res.json())
  .then((datos) => {
    datosGlobal = datos

    mostrarDatos(datosGlobal)
    llenarCategorias(datosGlobal)
    crearGraficos(datosGlobal)
  })
  .catch((error) => console.error('Error:', error))
