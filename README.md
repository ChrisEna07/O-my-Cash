# 💰 O-myCash by ChrizDev

![O-myCash Header](https://source.unsplash.com/featured/?finance,money,luxury)

**O-myCash** es una aplicación de gestión financiera personal diseñada para brindarte el control total de tu dinero utilizando la inteligencia de la **Regla 50/30/20**. Desarrollada con Flutter y potenciada por Supabase, ofrece una experiencia premium, oscura y moderna para transformar tus hábitos de ahorro.

---

## ✨ Características Principales

### 📈 Metodología 50/30/20
Administra tus finanzas automáticamente dividiendo tus ingresos netos en:
- **50% Necesidades**: Vivienda, comida, servicios y transporte.
- **30% Deseos**: Ocio, ropa, restaurantes y caprichos.
- **20% Ahorro e Inversión**: Construye tu futuro y fondo de emergencia.

### 🎯 Metas de Ahorro Inteligentes
- Crea metas personalizadas con fechas límite.
- **Inyección Directa**: Asigna tus ingresos directamente a una meta específica para ver crecer tu progreso visualmente.
- Notificaciones de celebración cuando alcanzas el 100% de tu objetivo.

### 🧠 Coach Financiero Personalizado
- Saludo personalizado al ingresar.
- **Estadísticas en tiempo real**: La app analiza tu comportamiento. Si estás cumpliendo la regla, ¡te felicita! Si te excedes, te brinda **tips de economía** y control financiero para ayudarte a retomar el rumbo.

### 🔔 Notificaciones y Recordatorios
- **Recordatorio Diario**: Notificación automática a las 9:00 AM para que no olvides registrar tus movimientos.
- **Alertas de Logro**: Notificaciones instantáneas al cumplir tus propósitos de ahorro.

### 🔐 Seguridad y Sincronización
- Autenticación segura mediante **Supabase Auth**.
- Base de datos en tiempo real con **Row Level Security (RLS)**: solo tú puedes ver y gestionar tus datos.
- Persistencia de sesión y recuerdo de credenciales para un acceso ágil.

---

## 🚀 Tecnologías Utilizadas

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **Estado**: Provider
- **Diseño**: Premium Dark Theme, Google Fonts (Outfit), Lucide Icons
- **Notificaciones**: Flutter Local Notifications
- **Gráficos**: Fl Chart

---

## 🛠️ Instalación y Configuración

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/ChrisEna07/O-my-Cash.git
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Configurar Supabase**:
   Crea un archivo `lib/core/supabase_config.dart` con tus credenciales:
   ```dart
   class SupabaseConfig {
     static const String url = 'TU_SUPABASE_URL';
     static const String anonKey = 'TU_ANON_KEY';
   }
   ```

4. **Configurar Base de Datos**:
   Ejecuta el script contenido en `supabase_schema.sql` en el SQL Editor de tu Dashboard de Supabase.

5. **Ejecutar**:
   ```bash
   flutter run
   ```

---

## 📱 Capturas de Pantalla (Próximamente)
*Desliza para ver la interfaz premium en modo oscuro.*

---

## 👨‍💻 Desarrollado por
**ChrizDev** - Creando soluciones financieras modernas y elegantes.

---
*Este proyecto es parte del ecosistema de aplicaciones diseñadas para mejorar la calidad de vida financiera de los usuarios.*
