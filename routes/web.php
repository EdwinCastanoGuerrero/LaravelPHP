<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Site\SiteController;
use App\Http\Controllers\Site\SupportController;

Route::get('/home', [SiteController::class, 'index']);


Route::get('/forum', [SupportController::class, 'index']);
