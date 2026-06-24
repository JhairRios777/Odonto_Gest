<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión | <?= APP_NAME ?></title>

    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- SweetAlert2 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">

    <style>
        *, *::before, *::after { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
            background: #F0F3F8;
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
        }

        /* ── Wrapper split ─────────────────────────── */
        .login-wrapper {
            display: flex;
            width: min(960px, 96vw);
            min-height: 560px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 24px 64px rgba(17,44,92,0.22);
        }

        /* ── Panel izquierdo — azul ─────────────────── */
        .login-left {
            flex: 0 0 42%;
            background: linear-gradient(145deg, #1A56AB 0%, #0C1F46 100%);
            padding: 48px 40px;
            display: flex; flex-direction: column; justify-content: space-between;
            position: relative; overflow: hidden;
        }
        /* Círculos decorativos */
        .login-left::before {
            content: ''; position: absolute; border-radius: 50%;
            background: rgba(255,255,255,0.06);
            width: 320px; height: 320px; top: -80px; right: -80px;
        }
        .login-left::after {
            content: ''; position: absolute; border-radius: 50%;
            background: rgba(255,255,255,0.05);
            width: 220px; height: 220px; bottom: -60px; left: -60px;
        }
        .circle-sm {
            position: absolute; border-radius: 50%;
            background: rgba(255,255,255,0.04);
            width: 160px; height: 160px; bottom: 90px; right: -40px;
        }
        /* Brand */
        .login-brand { display:flex; align-items:center; gap:12px; position:relative; z-index:1; }
        .login-brand-icon {
            width:48px; height:48px; background:rgba(255,255,255,.15);
            border-radius:12px; display:flex; align-items:center; justify-content:center;
            font-size:1.4rem; color:#fff;
        }
        .login-brand-name  { font-size:1.45rem; font-weight:800; color:#fff; line-height:1.2; }
        .login-brand-sub   { font-size:.7rem; color:rgba(255,255,255,.5); text-transform:uppercase; letter-spacing:1.5px; }
        /* Centro */
        .login-center { position:relative; z-index:1; }
        .login-center h2 { font-size:1.5rem; font-weight:800; color:#fff; margin:0 0 8px; }
        .login-center p  { font-size:.87rem; color:rgba(255,255,255,.65); margin:0 0 26px; }
        .login-features  { list-style:none; padding:0; margin:0; }
        .login-features li {
            display:flex; align-items:center; gap:10px;
            font-size:.83rem; color:rgba(255,255,255,.75); margin-bottom:11px;
        }
        .login-features li .fi {
            width:26px; height:26px; background:rgba(178,218,255,.15);
            border-radius:50%; display:flex; align-items:center; justify-content:center;
            font-size:.72rem; color:#B2DAFF; flex-shrink:0;
        }
        /* Pie */
        .login-left-foot { position:relative; z-index:1; font-size:.74rem; color:rgba(255,255,255,.35); }

        /* ── Panel derecho — blanco ─────────────────── */
        .login-right {
            flex:1; background:#fff; padding:52px 48px;
            display:flex; flex-direction:column; justify-content:center;
        }
        .login-right h1   { font-size:1.65rem; font-weight:800; color:#1A2940; margin:0 0 4px; }
        .login-right .sub { font-size:.87rem; color:#6B7280; margin:0 0 30px; }
        /* Alerta expirada */
        .alert-exp {
            background:rgba(217,119,6,.08); border:1px solid rgba(217,119,6,.22);
            border-radius:8px; padding:10px 14px; font-size:.83rem; color:#92400e;
            margin-bottom:18px; display:flex; align-items:center; gap:8px;
        }
        /* Labels azules */
        .login-label { font-size:.82rem; font-weight:600; color:#1A56AB; margin-bottom:5px; display:block; }
        /* Input */
        .inp-wrap { position:relative; margin-bottom:18px; }
        .login-inp {
            width:100%; background:#F5F7FB; border:1.5px solid #DDE4EF;
            border-radius:9px; padding:11px 40px 11px 42px;
            font-size:.9rem; color:#1A2940; outline:none; font-family:inherit;
            transition:border-color .2s, box-shadow .2s;
        }
        .login-inp:focus { border-color:#1A56AB; box-shadow:0 0 0 3px rgba(26,86,171,.14); background:#fff; }
        .login-inp::placeholder { color:#9CA3AF; }
        .inp-ico {
            position:absolute; left:14px; top:50%; transform:translateY(-50%);
            color:#9CA3AF; font-size:.84rem; pointer-events:none;
            transition:color .2s;
        }
        .inp-wrap:focus-within .inp-ico { color:#1A56AB; }
        .btn-eye {
            position:absolute; right:13px; top:50%; transform:translateY(-50%);
            background:none; border:none; color:#9CA3AF; cursor:pointer;
            font-size:.84rem; padding:0; transition:color .2s;
        }
        .btn-eye:hover { color:#1A56AB; }
        /* Botón submit */
        .btn-login {
            width:100%; background:#1A56AB; color:#fff; border:none;
            border-radius:9px; padding:12px; font-size:.95rem; font-weight:700;
            cursor:pointer; font-family:inherit; margin-top:4px;
            transition:background .2s, box-shadow .2s;
        }
        .btn-login:hover   { background:#154a96; box-shadow:0 6px 20px rgba(26,86,171,.32); }
        .btn-login:disabled{ opacity:.65; cursor:not-allowed; }
        /* Error */
        .login-err {
            background:rgba(220,38,38,.07); border:1px solid rgba(220,38,38,.18);
            border-radius:8px; padding:10px 14px; font-size:.83rem; color:#b91c1c;
            margin-top:12px; display:none; align-items:center; gap:8px;
        }
        .login-err.show { display:flex; }

        @media(max-width:640px){
            .login-wrapper{ flex-direction:column; width:100%; min-height:100vh; border-radius:0; }
            .login-left   { flex:none; padding:32px 24px; }
            .login-center h2{ font-size:1.2rem; }
            .login-features { display:none; }
            .login-right  { padding:36px 24px; }
        }
    </style>
</head>
<body>

<div class="login-wrapper">

    <!-- Panel izquierdo -->
    <div class="login-left">
        <div class="circle-sm"></div>

        <div class="login-brand">
            <div class="login-brand-icon"><i class="fas fa-tooth"></i></div>
            <div>
                <div class="login-brand-name">OdontoGest</div>
                <div class="login-brand-sub">Sistema de Gestión Odontológica</div>
            </div>
        </div>

        <div class="login-center">
            <h2>Gestión Odontológica Inteligente</h2>
            <p>Administra tu clínica de manera eficiente y segura desde un solo lugar.</p>
            <ul class="login-features">
                <li><span class="fi"><i class="fas fa-calendar-check"></i></span> Agenda de citas integrada</li>
                <li><span class="fi"><i class="fas fa-folder-open"></i></span> Expedientes clínicos digitales</li>
                <li><span class="fi"><i class="fas fa-file-invoice-dollar"></i></span> Facturación y tesorería</li>
                <li><span class="fi"><i class="fas fa-boxes-stacked"></i></span> Control de inventario</li>
                <li><span class="fi"><i class="fas fa-shield-alt"></i></span> Acceso seguro por roles</li>
            </ul>
        </div>

        <div class="login-left-foot">
            Clínica Dental Paz — Honduras &copy; <?= date('Y') ?>
        </div>
    </div>

    <!-- Panel derecho -->
    <div class="login-right">
        <h1>Bienvenido</h1>
        <p class="sub">Ingresa tus credenciales para continuar</p>

        <?php if (!empty($expired)): ?>
        <div class="alert-exp">
            <i class="fas fa-clock"></i>
            Tu sesión expiró por inactividad. Por favor vuelve a iniciar sesión.
        </div>
        <?php endif; ?>

        <form id="frmLogin" novalidate>
            <input type="hidden" id="csrf" value="<?= htmlspecialchars(Csrf::token()) ?>">

            <label class="login-label" for="inputU">Usuario</label>
            <div class="inp-wrap">
                <input class="login-inp" type="text" id="inputU" placeholder="Nombre de usuario"
                       autocomplete="username" required>
                <i class="fas fa-user inp-ico"></i>
            </div>

            <label class="login-label" for="inputP">Contraseña</label>
            <div class="inp-wrap">
                <input class="login-inp" type="password" id="inputP" placeholder="Contraseña"
                       autocomplete="current-password" required>
                <i class="fas fa-lock inp-ico"></i>
                <button type="button" class="btn-eye" id="btnEye" tabindex="-1">
                    <i class="fas fa-eye" id="icoEye"></i>
                </button>
            </div>

            <div class="login-err" id="errBox">
                <i class="fas fa-exclamation-circle"></i>
                <span id="errMsg"></span>
            </div>

            <button type="submit" class="btn-login" id="btnLogin">
                <span id="btnTxt"><i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión</span>
                <span id="btnSpin" style="display:none;">
                    <span class="spinner-border spinner-border-sm me-2"></span>Verificando...
                </span>
            </button>
        </form>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
(function(){
    const APP_URL = '<?= APP_URL ?>';
    const form    = document.getElementById('frmLogin');
    const btn     = document.getElementById('btnLogin');
    const btnTxt  = document.getElementById('btnTxt');
    const spin    = document.getElementById('btnSpin');
    const errBox  = document.getElementById('errBox');
    const errMsg  = document.getElementById('errMsg');

    document.getElementById('btnEye')?.addEventListener('click',()=>{
        const p = document.getElementById('inputP');
        const i = document.getElementById('icoEye');
        const v = p.type==='password';
        p.type       = v ? 'text' : 'password';
        i.className  = v ? 'fas fa-eye-slash' : 'fas fa-eye';
    });

    const setLoad = on => {
        btn.disabled = on;
        btnTxt.style.display = on ? 'none' : '';
        spin.style.display   = on ? ''     : 'none';
    };
    const showErr = m => { errMsg.textContent=m; errBox.classList.add('show'); };
    const clearErr= ()=> errBox.classList.remove('show');

    ['inputU','inputP'].forEach(id=>document.getElementById(id)?.addEventListener('input',clearErr));

    form.addEventListener('submit', async e=>{
        e.preventDefault();
        clearErr();
        const usuario    = document.getElementById('inputU').value.trim();
        const contrasena = document.getElementById('inputP').value;
        const _csrf      = document.getElementById('csrf').value;

        if(!usuario||!contrasena){ showErr('Completa usuario y contraseña.'); return; }

        setLoad(true);
        try {
            const r = await fetch(APP_URL+'Auth/procesarLogin',{
                method:'POST',
                headers:{'Content-Type':'application/json'},
                body:JSON.stringify({usuario,contrasena,_csrf})
            });
            const d = await r.json();
            if(d.success){ window.location.href=d.redirect; }
            else { showErr(d.error||'Credenciales incorrectas.'); setLoad(false); }
        } catch(_){ showErr('Error de conexión. Verifica tu red.'); setLoad(false); }
    });
})();
</script>
</body>
</html>
