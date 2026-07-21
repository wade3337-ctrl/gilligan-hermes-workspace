<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>

<title>Financial Report Dashboard</title>

<style>
h1
{
    font-size:32px;
    margin-bottom:15px;
}

.navbar-brand
{
    font-size:20px;
}

.container
{
    margin-top:10px;
    margin-bottom:10px;
}

th 
{
    background-color: #343A40 !important;
    color: white;
}

@media only screen and (max-width: 800px) 
{
    .hideMobile
    {
        display:none !important;
    }
}

@media only screen and (max-width: 500px) 
{
    .pagination, #mySelectionCount222, .btn
    {
        font-size:12px !important;
    }
}

.btn-success
{
    background-color:#5C743C !important;
    border: none !important;
}

.btn-success:hover, .btn:hover, .dropdown-item:hover, .page-item.active:hover
{
   filter: brightness(1.20);
}

.ms-n5 
{
    margin-left: -40px;
}

.nav-link
{
    color:black !important;
}

.table 
{
    border-radius: 4px !important;
}

@media (min-width: 1200px) {
    .h1, h1 {
        font-size: 32px !important;
    }
}

    .h1, h1 {
        font-size: 32px !important;
    }

.active, .page-link
{
    color:#5C743C !important;
}

.btn, .page-item.active .page-link
{
    background-color:#5C743C !important;
    color:white !important;
    border-color:#5C743C !important;
}

.dropdown-item.active, .dropdown-item:active
{
    background-color:lightgrey !important;
    color:white !important;
}

.form-check-input:checked
{
    background-color:#5C743C !important;
    border-color:#5C743C !important;
}

.fa-search
{
    color:#6C757D !important;
}

.myLink 
{
    text-decoration:none;
    color:white;
}

.myLink:hover 
{
    text-decoration:none;
    color:white;
}

.myLink2
{
    text-decoration:none;
    color:black;
}

.myLink2:hover
{
    text-decoration:none;
    color:white;
}

.myLinkContainer,.myLinkContainer2
{
    float:left;
    display:inline;
    border:1px solid #5C743C;
    padding:10px 10px;
    width:50% !important;
    text-align:center;
}

.myLinkContainer:hover 
{
    filter: brightness(1.20);
}

.myLinkContainer2:hover 
{
    background-color:gray !important;
    filter: brightness(1.20);
   color:white !important;
}

tbody, td, tfoot, th, thead, tr
{
    padding:4px 10px !important;
}

.table a 
{
    color:#5C743C !important;
}

.bg-light
{
    background-color:#F8F9FA !important;
    color:#495057 !important;
}

.navbar-light .navbar-toggler
{
    display:none !important;
}

.border
{
    border:1px solid #9DAC8A !important;
}
</style>