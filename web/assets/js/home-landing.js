/* home-landing.js — Landing page interactions */

document.addEventListener('DOMContentLoaded', function () {

    // Init Lucide icons
    lucide.createIcons();

    // Navbar scroll effect
    const nav = document.getElementById('homeNav');
    window.addEventListener('scroll', () => {
        nav.classList.toggle('scrolled', window.scrollY > 40);
    });

    // Hero bg load animation (subtle zoom-out)
    const heroBg = document.getElementById('heroBg');
    if (heroBg) setTimeout(() => heroBg.classList.add('loaded'), 100);

    // Floating particles in hero
    const container = document.getElementById('particles');
    if (container) {
        for (let i = 0; i < 18; i++) {
            const p = document.createElement('div');
            p.className = 'particle';
            p.style.left              = Math.random() * 100 + '%';
            p.style.width             = (Math.random() * 4 + 2) + 'px';
            p.style.height            = p.style.width;
            p.style.animationDuration = (Math.random() * 12 + 8) + 's';
            p.style.animationDelay    = (Math.random() * 10) + 's';
            p.style.opacity           = Math.random() * 0.6 + 0.1;
            container.appendChild(p);
        }
    }

    // Scroll-reveal for cards and steps
    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(e => {
            if (e.isIntersecting) {
                e.target.style.opacity   = '1';
                e.target.style.transform = 'translateY(0)';
            }
        });
    }, { threshold: 0.1 });

    document.querySelectorAll('.feature-card, .step-item').forEach((el, i) => {
        el.style.opacity    = '0';
        el.style.transform  = 'translateY(30px)';
        el.style.transition = `opacity 0.6s ease ${i * 0.07}s, transform 0.6s ease ${i * 0.07}s`;
        revealObserver.observe(el);
    });
});
