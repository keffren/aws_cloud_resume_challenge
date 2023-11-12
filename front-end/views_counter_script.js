/*
* AWS CLOUD RESUME CHALLENGE
*  Include a visitor counter that displays how many people have accessed the site
*/

//Retrieve the views
let views = getViews();
document.getElementById("views-counter").innerHTML = views;

//Increment and store the counter
views++;
localStorage.setItem("views-counter", views);

function getViews(){

    let views = localStorage.getItem("views-counter");

    if(views === null){
        views = 1;
        localStorage.setItem("views-counter", views);
    }else{
        views = localStorage.getItem("views-counter");
    };

    return views;
};
