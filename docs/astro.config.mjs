import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLinksValidator from 'starlight-links-validator';
import tailwindcss from '@tailwindcss/vite';

const site = 'https://bloclibrary.dev/';
const locales = {
	root: { label: 'English', lang: 'en' },
	az: { label: 'Azərbaycan', lang: 'az' },
	cs: { label: 'Čeština', lang: 'cs' },
	de: { label: 'Deutsch', lang: 'de' },
	es: { label: 'Español', lang: 'es' },
	fil: { label: 'Filipino', lang: 'fil' },
	fr: { label: 'Français', lang: 'fr' },
	it: { label: 'Italiano', lang: 'it' },
	ja: { label: '日本語', lang: 'ja' },
	ko: { label: '한국어', lang: 'ko' },
	'pt-br': { label: 'Português', lang: 'pt-BR' },
	ru: { label: 'Русский', lang: 'ru' },
	'zh-cn': { label: '简体中文', lang: 'zh-CN' },
	ar: { label: 'العربية', lang: 'ar', dir: 'rtl' },
	fa: { label: 'فارسی', lang: 'fa', dir: 'rtl' },
	bn: { label: 'বাংলা', lang: 'bn' },
};

// https://astro.build/config
export default defineConfig({
	site,
	integrations: [
		starlight({
			expressiveCode: { themes: ['dark-plus', 'github-light'] },
			logo: {
				light: 'src/assets/light-bloc-logo.svg',
				dark: 'src/assets/dark-bloc-logo.svg',
				replacesTitle: true,
			},
			title: 'Bloc',
			editLink: { baseUrl: 'https://github.com/felangel/bloc/edit/master/docs/' },
			tagline: 'A predictable state management library for Dart.',
			favicon: 'favicon.ico',
			head: [
				{ tag: 'meta', attrs: { property: 'og:image', content: site + 'og.png?v=1' } },
				{ tag: 'meta', attrs: { property: 'twitter:image', content: site + 'og.png?v=1' } },
			],
			customCss: ['src/tailwind.css', 'src/styles/landing.css', '@fontsource-variable/figtree'],
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/felangel/bloc' },
				{ icon: 'discord', label: 'Discord', href: 'https://discord.gg/bloc' },
			],
			defaultLocale: 'root',
			locales,
			sidebar: [
				{
					label: 'Introduction',
					translations: {
						'zh-CN': '介绍',
						fa: 'مقدمه',
						es: 'Introducción',
						ja: '紹介',
						ru: 'Введение',
					},
					items: [
						{
							label: 'Getting Started',
							link: '/getting-started/',
							translations: {
								'zh-CN': '快速入门',
								fa: 'شروع شدن',
								es: 'Empezando',
								ja: 'はじめに',
								ru: 'Начало работы',
							},
						},
						{
							label: 'Why Bloc?',
							link: '/why-bloc/',
							translations: {
								'zh-CN': '为什么用 Bloc?',
								fa: 'چرا Bloc؟',
								es: '¿Por qué Bloc?',
								ja: 'なぜBloc？',
								ru: 'Почему Bloc?',
							},
						},
						{
							label: 'Bloc Concepts',
							link: '/bloc-concepts/',
							translations: {
								'zh-CN': 'Bloc 核心概念',
								fa: 'مفاهیم Bloc',
								es: 'Conceptos de Bloc',
								ja: 'Blocのコンセプト',
								ru: 'Концепции Bloc',
							},
						},
						{
							label: 'Flutter Bloc Concepts',
							link: '/flutter-bloc-concepts/',
							translations: {
								'zh-CN': 'Flutter Bloc 核心概念',
								fa: 'مفاهیم Bloc فلاتر',
								es: 'Conceptos de Flutter Bloc',
								ja: 'Flutter Blocのコンセプト',
								ru: 'Концепции Flutter Bloc',
							},
						},
						{
							label: 'Architecture',
							link: '/architecture/',
							translations: {
								fa: 'معماری',
								es: 'Arquitectura',
								ja: 'アーキテクチャー',
								ru: 'Архитектура',
							},
						},
						{
							label: 'Modeling State',
							link: '/modeling-state/',
							translations: {
								fa: 'حالت (State) مدل سازی',
								es: 'Modelando el Estado',
								ja: '状態のモデリング',
								ru: 'Моделирование состояния',
							},
						},
						{
							label: 'Testing',
							link: '/testing/',
							translations: { fa: 'آزمایش کردن', es: 'Pruebas', ja: 'テスト', ru: 'Тестирование' },
						},
						{
							label: 'Naming Conventions',
							link: '/naming-conventions/',
							translations: {
								fa: 'قراردادهای نامگذاری',
								es: 'Convenciones de Nomenclatura',
								ja: '命名規則',
								ru: 'Соглашения об именовании',
							},
						},
						{
							label: 'Migration Guide',
							link: '/migration/',
							translations: {
								fa: 'راهنمای مهاجرت',
								es: 'Guía de Migración',
								ja: '移行ガイド',
								ru: 'Руководство по миграции',
							},
						},
						{
							label: 'FAQs',
							link: '/faqs/',
							translations: {
								fa: 'سوالات متداول',
								es: 'Preguntas Frecuentes',
								ja: 'よくある質問',
								ru: 'Часто задаваемые вопросы',
							},
						},
					],
				},
				{
					label: 'Linter',
					badge: { text: 'new' },
					items: [
						{
							label: 'Overview ',
							link: '/lint/',
							translations: { fa: 'بررسی اجمالی', ru: 'Обзор' },
						},
						{
							label: 'Installation ',
							link: '/lint/installation/',
							translations: { fa: 'نصب', ru: 'Установка' },
						},
						{
							label: 'Configuration ',
							link: '/lint/configuration/',
							translations: { fa: 'پیکربندی', ru: 'Конфигурация' },
						},
						{
							label: 'Customizing Rules ',
							link: '/lint/customizing-rules/',
							translations: { fa: 'سفارشی سازی قوانین', ru: 'Настройка правил' },
						},
						{
							label: 'Rules',
							autogenerate: { directory: '/lint-rules' },
							translations: { fa: 'قوانین', ru: 'Правила' },
						},
					],
				},
				{
					label: 'Tutorials',
					translations: {
						fa: 'آموزش ها',
						es: 'Tutoriales',
						ja: 'チュートリアル',
						ru: 'Руководства',
					},
					autogenerate: { directory: 'tutorials' },
				},
				{
					label: 'Tools',
					translations: { fa: 'ابزار', es: 'Herramientas', ja: 'ツール', ru: 'Инструменты' },
					items: [
						{
							label: 'IntelliJ Plugin',
							link: 'https://plugins.jetbrains.com/plugin/12129-bloc',
							translations: {
								fa: 'پلاگین IntelliJ',
								es: 'Plugin de IntelliJ',
								ru: 'Плагин IntelliJ',
							},
						},
						{
							label: 'VSCode Extension',
							link: 'https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc',
							translations: {
								fa: 'پلاگین VSCode',
								es: 'Extensión de VSCode',
								ru: 'Расширение VSCode',
							},
						},
					],
				},
				{
					label: 'Reference',
					translations: { fa: 'مرجع', es: 'Referencia', ja: 'APIリファレンス', ru: 'Справочник' },
					items: [
						{
							label: 'angular_bloc',
							link: 'https://pub.dev/documentation/angular_bloc/latest/index.html',
						},
						{ label: 'bloc', link: 'https://pub.dev/documentation/bloc/latest/index.html' },
						{
							label: 'bloc_concurrency',
							link: 'https://pub.dev/documentation/bloc_concurrency/latest/index.html',
						},
						{
							label: 'bloc_lint',
							link: 'https://pub.dev/documentation/bloc_lint/latest/index.html',
						},
						{
							label: 'bloc_test',
							link: 'https://pub.dev/documentation/bloc_test/latest/index.html',
						},
						{
							label: 'bloc_tools',
							link: 'https://pub.dev/documentation/bloc_tools/latest/index.html',
						},
						{
							label: 'flutter_bloc',
							link: 'https://pub.dev/documentation/flutter_bloc/latest/index.html',
						},
						{
							label: 'hydrated_bloc',
							link: 'https://pub.dev/documentation/hydrated_bloc/latest/index.html',
						},
						{
							label: 'replay_bloc',
							link: 'https://pub.dev/documentation/replay_bloc/latest/index.html',
						},
					],
				},
			],
			plugins: [
				starlightLinksValidator({ errorOnFallbackPages: false, errorOnInconsistentLocale: true }),
			],
		}),
	],
	vite: { plugins: [tailwindcss()] },
});
