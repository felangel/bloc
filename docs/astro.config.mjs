import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLinksValidator from 'starlight-links-validator';
import tailwind from '@astrojs/tailwind';

const site = 'https://bloclibrary.dev/';
const locales = {
	root: {
		label: 'English',
		lang: 'en',
	},
	az: {
		label: 'Azərbaycan',
		lang: 'az',
	},
	cs: {
		label: 'Čeština',
		lang: 'cs',
	},
	de: {
		label: 'Deutsch',
		lang: 'de',
	},
	es: {
		label: 'Español',
		lang: 'es',
	},
	fil: {
		label: 'Filipino',
		lang: 'fil',
	},
	fr: {
		label: 'Français',
		lang: 'fr',
	},
	ja: {
		label: '日本語',
		lang: 'ja',
	},
	ko: {
		label: '한국인',
		lang: 'ko',
	},
	'pt-br': {
		label: 'Português',
		lang: 'pt-BR',
	},
	ru: {
		label: 'Русский',
		lang: 'ru',
	},
	'zh-cn': {
		label: '简体中文',
		lang: 'zh-CN',
	},
	ar: {
		label: 'العربية',
		lang: 'ar',
	},
};

// https://astro.build/config
export default defineConfig({
	site,
	integrations: [
		starlight({
			expressiveCode: {
				themes: ['dark-plus', 'github-light'],
			},
			logo: {
				light: 'src/assets/light-bloc-logo.svg',
				dark: 'src/assets/dark-bloc-logo.svg',
				replacesTitle: true,
			},
			title: 'Bloc',
			editLink: {
				baseUrl: 'https://github.com/felangel/bloc/edit/master/docs/',
			},
			tagline: 'A predictable state management library for Dart.',
			favicon: 'favicon.ico',
			head: [
				{
					tag: 'meta',
					attrs: { property: 'og:image', content: site + 'og.png?v=1' },
				},
				{
					tag: 'meta',
					attrs: { property: 'twitter:image', content: site + 'og.png?v=1' },
				},
			],
			customCss: ['src/tailwind.css', 'src/styles/landing.css', '@fontsource-variable/figtree'],
			social: {
				github: 'https://github.com/felangel/bloc',
				discord: 'https://discord.gg/bloc',
			},
			defaultLocale: 'root',
			locales,
			sidebar: [
				{
					label: 'Introduction',
					items: [
						{
							label: 'Getting Started',
							link: '/getting-started',
						},
						{
							label: 'Why Bloc?',
							link: '/why-bloc',
						},
						{
							label: 'Bloc Concepts',
							link: '/bloc-concepts',
						},
						{
							label: 'Flutter Bloc Concepts',
							link: '/flutter-bloc-concepts',
						},
						{
							label: 'Architecture',
							link: '/architecture',
						},
						{
							label: 'Testing',
							link: '/testing',
						},
						{
							label: 'Naming Conventions',
							link: '/naming-conventions',
						},
						{
							label: 'FAQs',
							link: '/faqs',
						},
						{
							label: 'Migration Guide',
							link: '/migration',
						},
					],
				},
				{
					label: 'Tutorials',
					autogenerate: {
						directory: 'tutorials',
					},
				},
				{
					label: 'Tools',
					items: [
						{
							label: 'IntelliJ Plugin',
							link: 'https://plugins.jetbrains.com/plugin/12129-bloc',
						},
						{
							label: 'VSCode Extension',
							link: 'https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc',
						},
					],
				},
				{
					label: 'Reference',
					items: [
						{
							label: 'angular_bloc',
							link: 'https://pub.dev/documentation/angular_bloc/latest/index.html',
						},
						{
							label: 'bloc',
							link: 'https://pub.dev/documentation/bloc/latest/index.html',
						},
						{
							label: 'bloc_concurrency',
							link: 'https://pub.dev/documentation/bloc_concurrency/latest/index.html',
						},
						{
							label: 'bloc_test',
							link: 'https://pub.dev/documentation/bloc_test/latest/index.html',
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
				starlightLinksValidator({
					errorOnFallbackPages: false,
					errorOnInconsistentLocale: true,
				}),
			],
		}),
		tailwind({ applyBaseStyles: false }),
	],
});
