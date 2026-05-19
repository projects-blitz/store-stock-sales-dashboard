-- =========================================
-- PROYECTO: TIENDA DE ABARROTES
-- AUTOR: Fernando Balarezo
-- DESCRIPCIÓN: Base de datos para análisis de ventas
-- =========================================

-- =========================================
-- 1. CREAR BASE DE DATOS
-- =========================================
CREATE DATABASE TiendaAbarrotes;
GO

USE TiendaAbarrotes;
GO


-- =========================================
-- 2. CREAR TABLAS
-- =========================================

-- Tabla: Categorias
CREATE TABLE Categorias (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- Tabla: Productos
CREATE TABLE Productos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_categoria INT,
    precio DECIMAL(10,2) NOT NULL,
    stock_actual INT NOT NULL,

    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

-- Tabla: Ventas
CREATE TABLE Ventas (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    total DECIMAL(10,2) NOT NULL
);

-- Tabla: Detalle de ventas
CREATE TABLE Detalle_Venta (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);


-- =========================================
-- 3. INSERTAR DATOS
-- =========================================

-- Categorías
INSERT INTO Categorias (nombre) VALUES
('Bebidas'),
('Snacks'),
('Aseo'),
('Lácteos'),
('Abarrotes');


-- Productos (ejemplo inicial)
INSERT INTO Productos (nombre, id_categoria, precio, stock_actual) VALUES
('Coca Cola 500ml', 1, 2.50, 100),
('Agua San Luis 625ml', 1, 1.20, 150),
('Papas Lays', 2, 1.80, 60),
('Galletas Oreo', 2, 2.00, 50),
('Detergente Ariel', 3, 8.50, 30),
('Leche Gloria', 4, 3.20, 70),
('Arroz 1kg', 5, 4.00, 90);


-- Ventas
INSERT INTO Ventas (total) VALUES
(12.50),
(8.40),
(15.00);


-- Detalle de ventas
INSERT INTO Detalle_Venta (id_venta, id_producto, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 2, 2.50, 5.00),
(1, 3, 3, 1.80, 5.40),
(2, 4, 2, 2.00, 4.00),
(2, 6, 1, 3.20, 3.20),
(3, 1, 3, 2.50, 7.50),
(3, 7, 2, 4.00, 8.00);


-- =========================================
-- 4. VISTA PARA ANÁLISIS (POWER BI)
-- =========================================

CREATE VIEW vw_ventas_detalle AS
SELECT 
    v.id_venta,
    v.fecha,
    p.nombre AS producto,
    c.nombre AS categoria,
    dv.cantidad,
    dv.precio_unitario,
    dv.subtotal
FROM Detalle_Venta dv
JOIN Ventas v ON dv.id_venta = v.id_venta
JOIN Productos p ON dv.id_producto = p.id_producto
JOIN Categorias c ON p.id_categoria = c.id_categoria;


-- =========================================
-- 5. CONSULTAS DE ANÁLISIS (OPCIONAL)
-- =========================================

-- Productos más vendidos
SELECT 
    producto,
    SUM(cantidad) AS total_vendido
FROM vw_ventas_detalle
GROUP BY producto
ORDER BY total_vendido DESC;

-- Ventas por categoría
SELECT 
    categoria,
    SUM(subtotal) AS total_ventas
FROM vw_ventas_detalle
GROUP BY categoria
ORDER BY total_ventas DESC;

-- Ventas totales
SELECT SUM(total) AS ventas_totales
FROM Ventas;