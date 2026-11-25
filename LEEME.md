# Impulso · app web instalable

Impulso se abre desde un link, se instala en el celular (iPhone y Android) y guarda los datos de cada persona en su propia cuenta. El entrenador ve a todo el equipo en la pestaña **Equipo**.

## Qué hay en esta carpeta

| Archivo | Para qué sirve |
|---|---|
| `index.html` | La app completa |
| `config.js` | Los datos de tu proyecto de Supabase (paso 1) |
| `manifest.webmanifest`, `sw.js`, `icons/` | Lo que permite instalarla en el celular con el ícono de Impulso |
| `vendor/supabase.js` | La librería para hablar con Supabase |
| `supabase/schema.sql` | La base de datos y los permisos (paso 1) |
| `mis-datos-hibrid.json` (va aparte, no está en esta carpeta) | Tus entrenos actuales de Hibrid, para importarlos (paso 4) |

---

## Paso 1 · Base de datos en Supabase (unos 10 minutos)

1. Entrá a **supabase.com** y creá una cuenta gratis (podés usar tu cuenta de GitHub o Google).
2. **New project**. Nombre: `impulso`. Elegí una contraseña de base de datos y guardala. Región: **South America (São Paulo)**, que es la más cerca.
3. Cuando termine de crearse: menú izquierdo → **SQL Editor** → **New query**. Pegá todo el contenido de `supabase/schema.sql` y tocá **Run**. Tiene que decir *Success*.
4. Menú izquierdo → **Authentication** → **Sign In / Providers** → **Email**: desactivá **Confirm email** y guardá. Así las jugadoras entran al instante, sin tener que confirmar un mail.
5. Menú izquierdo → **Project Settings** → **API** (o **Data API**). Copiá:
   - **Project URL** (algo como `https://abcd1234.supabase.co`)
   - la clave **anon public**
6. Abrí `config.js` y pegá esos dos datos entre las comillas.

> La clave *anon public* está pensada para ir dentro de la app. Lo que protege los datos son los permisos del paso 3: cada jugadora solo puede leer y escribir lo suyo, y el entrenador puede leer todo.

## Paso 2 · Publicar la app en GitHub Pages (gratis)

1. Entrá a **github.com** → **New repository**. Nombre: `impulso`. Tiene que ser **Public** para que GitHub Pages sea gratis. Los datos no quedan ahí, solo el código.
2. **Add file → Upload files**: arrastrá **todo el contenido** de esta carpeta, con las subcarpetas `icons`, `vendor` y `supabase` incluidas. El archivo `mis-datos-hibrid.json` va aparte y **no se sube**: tiene tus entrenos y el repositorio es público. Tocá **Commit changes**.
3. **Settings → Pages** → en *Branch* elegí `main` y la carpeta `/ (root)` → **Save**.
4. En uno o dos minutos aparece tu link, por ejemplo `https://tu-usuario.github.io/impulso/`.

Más adelante se puede usar un dominio propio, como `impulso.com.ar`, desde la misma pantalla de Pages.

## Paso 3 · Tu cuenta de entrenador

1. Abrí tu link → **Crear cuenta** con tu nombre, tu mail y una contraseña.
2. Volvé a Supabase → **SQL Editor** → **New query** y corré esta línea con **tu** mail:

   ```sql
   insert into public.coaches (user_id) select id from auth.users where email = 'TU_MAIL@ejemplo.com' on conflict do nothing;
   ```
3. Recargá la app: te aparece la pestaña **Equipo**.

## Paso 4 · Traer tus entrenos de Hibrid

En la app: **Perfil** → abajo de todo → **Importar datos de Hibrid (.json)** → elegí `mis-datos-hibrid.json`. Se cargan tu perfil, tus sesiones y tus programas.

## Paso 5 · Sumar jugadoras

Pasales el link. Cada una toca **Crear cuenta**, pone su nombre, mail y contraseña, y la instala:
- **iPhone:** Safari → botón Compartir → **Agregar a inicio**.
- **Android:** Chrome → menú ⋮ → **Instalar app** (o *Agregar a pantalla principal*).

---

## Cuando hagamos cambios

1. Reemplazá `index.html` en GitHub (Upload files → commit).
2. En `sw.js`, cambiá `impulso-v1` por `impulso-v2` (v3, v4… cada vez) y subilo también. Así los celulares descargan la versión nueva.

## Límites del plan gratis de Supabase (sobran para un equipo)

- 500 MB de base de datos y 1 GB de archivos (videos de ejercicios).
- Si el proyecto pasa **una semana sin uso**, Supabase lo pausa. Se reactiva desde el panel con un clic, sin perder nada. Si lo usan seguido, no pasa.

## Privacidad

La app guarda datos de salud y entrenamiento. Antes de abrirla a gente de afuera del equipo, conviene publicar una política de privacidad corta. Si alguna jugadora es menor de edad, pedí el consentimiento de sus padres.

## Próximos pasos posibles

- Aviso al instante por Telegram cuando una jugadora termina una sesión.
- Dominio propio (`impulso.com.ar`).
- Publicarla en Google Play.

La configuración se puede ir ajustando con el uso para lograr la mejor versión según lo que necesite el equipo.
