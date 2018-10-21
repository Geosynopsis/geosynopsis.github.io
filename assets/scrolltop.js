/**
 * Created by abheeman on 19.10.18.
 */
// When the user scrolls the page, execute myFunction
window.onscroll = function() {myFunction()};

// Get the header
var navElement = document.getElementById("main-nav");
var logo = document.getElementById("layer101");

// Get the offset position of the navbar
var sticky = 60 * window.innerHeight/100; //50vh

// Add the sticky class to the header when you reach its scroll position. Remove "sticky" when you leave the scroll position
function myFunction() {
  if (window.pageYOffset > sticky) {
    navElement.classList.add("fixed-top");
    navElement.classList.add("bg-light");
    navElement.classList.add("shadow");
    navElement.classList.remove("navbar-dark");
    navElement.classList.remove("bg-dark");
    logo.setAttribute("fill", "darkslateblue");
  } else {
    navElement.classList.remove("fixed-top");
    navElement.classList.remove("shadow");
    navElement.classList.remove("bg-light");
    navElement.classList.add("navbar-dark");
    navElement.classList.add("bg-dark");
    logo.setAttribute("fill", "white");
  }
}
