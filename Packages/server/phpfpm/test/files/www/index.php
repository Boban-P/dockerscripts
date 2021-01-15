<?php

if (isset($_SERVER['HTTPS'])) {
    echo '$_SERVER[HTTPS] = ' . $_SERVER['HTTPS'] . "\n";
}

if (isset($_SERVER['HTTP_HOST'])) {
    echo '$_SERVER[HTTP_HOST] = ' . $_SERVER['HTTP_HOST'] . "\n";
}
