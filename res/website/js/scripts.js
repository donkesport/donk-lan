/*!
* Start Bootstrap - Creative v7.0.6 (https://startbootstrap.com/theme/creative)
* Copyright 2013-2022 Start Bootstrap
* Licensed under MIT (https://github.com/StartBootstrap/startbootstrap-creative/blob/master/LICENSE)
*/
//
// Scripts
// 

window.addEventListener('DOMContentLoaded', event => {

    // Navbar shrink function
    var navbarShrink = function () {
        const navbarCollapsible = document.body.querySelector('#mainNav');
        if (!navbarCollapsible) {
            return;
        }
        if (window.scrollY === 0) {
            navbarCollapsible.classList.remove('navbar-shrink')
        } else {
            navbarCollapsible.classList.add('navbar-shrink')
        }

    };

    // Shrink the navbar 
    navbarShrink();

    // Shrink the navbar when page is scrolled
    document.addEventListener('scroll', navbarShrink);

    // Activate Bootstrap scrollspy on the main nav element
    const mainNav = document.body.querySelector('#mainNav');
    if (mainNav) {
        new bootstrap.ScrollSpy(document.body, {
            target: '#mainNav',
            offset: 74,
        });
    };

    // Collapse responsive navbar when toggler is visible
    const navbarToggler = document.body.querySelector('.navbar-toggler');
    const responsiveNavItems = [].slice.call(
        document.querySelectorAll('#navbarResponsive .nav-link')
    );
    responsiveNavItems.map(function (responsiveNavItem) {
        responsiveNavItem.addEventListener('click', () => {
            if (window.getComputedStyle(navbarToggler).display !== 'none') {
                navbarToggler.click();
            }
        });
    });

    // Activate SimpleLightbox plugin for portfolio items
    new SimpleLightbox({
        elements: '#portfolio a.portfolio-box'
    });

});


// countdown

let d = new Date('2022-05-25T23:00:00') - new Date();

const l = Array.from(document.querySelectorAll('span')).reverse();
const s = [1000,60,60,24];

const vset = (e,t,c) => {
    const m = c ? t % c : t;
    if (m < 0) {
        e.setAttribute('b', '--');
    }
    else
    {
        e.setAttribute('b', m < 10 ? '0' + m : m);
    }
    
    e.classList.remove('ping');
    setTimeout(() => e.classList.add('ping'), 10);
    return m;
};
const calc = (t,i=0,b=0) => {
    if (!s[i]) return;
    t = opti(t,s[i]);
    if (vset(l[i],t,s[i+1])==s[i+1]-1 || b) calc(t,i+1,b);
}

const count = (b=0) => (d -= 1000) && calc(d,0,b);
const opti = (v,n) => (v - (v % n)) / n;

setTimeout(() => !count(1) && setInterval(count, 1000), d % 1000);

