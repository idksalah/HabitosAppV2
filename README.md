# HabitosApp

## ¿Qué es HabitosApp?

HabitosApp es una aplicación desarrollada con Flutter que sirve para organizar los hábitos del día a día y llevar un control de los objetivos personales.

La idea es que el usuario pueda crear sus propios hábitos, marcar los que ha completado y ver cómo va progresando con el tiempo.

## ¿Qué se puede hacer con la aplicación?

- Configurar el perfil introduciendo el nombre y el objetivo diario.
- Añadir nuevos hábitos, editar sus nombres y colores o eliminarlos.
- Marcar los hábitos que se han completado cada día.
- Consultar cuántos días se ha realizado cada hábito y la racha actual.
- Ver cuántas veces se ha abierto la aplicación y cuándo fue la apertura anterior.
- Cambiar entre el tema claro y el oscuro.
- Modificar el tamaño de letra y elegir si se quieren ocultar los hábitos completados.
- Guardar los datos para que sigan disponibles al volver a abrir la aplicación.

## Tecnologías utilizadas

Para desarrollar el proyecto he utilizado:

- **Flutter y Dart**, para crear la aplicación.
- **SharedPreferences**, para guardar los datos y las preferencias del usuario en el dispositivo.
- **JSON**, para guardar y recuperar la información completa de los hábitos.

## Organización del proyecto

El código está separado en varias carpetas para que sea más fácil encontrar cada parte de la aplicación:

- `models/`: contiene la clase que representa los hábitos.
- `services/`: se encarga de guardar y recuperar los datos.
- `screens/`: contiene las diferentes pantallas de la aplicación.
- `widgets/`: contiene componentes reutilizables de la interfaz.
- `main.dart`: inicia la aplicación y configura el tema y la navegación.

## Cómo ejecutar el proyecto

Para ejecutar la aplicación, necesitas tener Flutter instalado y un dispositivo o emulador preparado.

1. Abre el proyecto en Android Studio.
2. Abre la terminal desde la carpeta del proyecto.
3. Ejecuta el siguiente comando para instalar las dependencias:

   ```bash
   flutter pub get
   ```

4. Si quieres comprobar el código, ejecuta:

   ```bash
   flutter analyze
   ```

5. Finalmente, inicia la aplicación:

   ```bash
   flutter run
   ```

## Sobre el proyecto

Este proyecto forma parte de mi aprendizaje en el desarrollo de aplicaciones con Flutter. Me ha permitido trabajar con la navegación entre pantallas, la gestión del estado, la creación de interfaces y el almacenamiento local de datos.

El objetivo es seguir mejorando la aplicación y aprender a organizar mejor el código a medida que avanzo.
# HabitosAppV2
