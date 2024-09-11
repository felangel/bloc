import { defineConfig } from 'astro/config';
import rehypeSlug from 'rehype-slug';
import { rehypeAutolink } from './plugins/rehype-autolink';
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
		label: '한국어',
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
		dir: 'rtl',
	},
	fa: {
		label: 'فارسی',
		lang: 'fa',
		dir: 'rtl',
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
			components: {
				MarkdownContent: './src/components/starlight/MarkdownContent.astro',
			},
			social: {
				github: 'https://github.com/felangel/bloc',
				discord: 'https://discord.gg/bloc',
			},
			defaultLocale: 'root',
			locales,
			sidebar: [
				{
					label: 'Introduction',
					translations: {
						'zh-CN': '介绍',
						fa: 'مقدمه',
					},
					items: [
						{
							label: 'Getting Started',
							link: '/getting-started/',
							translations: {
								'zh-CN': '快速入门',
								fa: 'شروع شدن',
							},
						},
						{
							label: 'Why Bloc?',
							link: '/why-bloc/',
							translations: {
								'zh-CN': '为什么用 Bloc?',
								fa: 'چرا Bloc؟',
							},
						},
						{
							label: 'Bloc Concepts',
							link: '/bloc-concepts/',
							translations: {
								'zh-CN': 'Bloc 核心概念',
								fa: 'مفاهیم Bloc',
							},
						},
						{
							label: 'Flutter Bloc Concepts',
							link: '/flutter-bloc-concepts/',
							translations: {
								'zh-CN': 'Flutter Bloc 核心概念',
								fa: 'مفاهیم بلوک فلاتر',
							},
						},
						{
							label: 'Architecture',
							link: '/architecture/',
							translations: {
								fa: 'معماری',
							},
						},
						{
							label: 'Modeling State',
							link: '/modeling-state/',
							translations: {
								fa: 'وضعیت (State) مدل سازی',
							},
						},
						{
							label: 'Testing',
							link: '/testing/',
							translations: {
								fa: 'آزمایش کردن',
							},
						},
						{
							label: 'Naming Conventions',
							link: '/naming-conventions/',
							translations: {
								fa: 'قراردادهای نامگذاری',
							},
						},
						{
							label: 'FAQs',
							link: '/faqs/',
							translations: {
								fa: 'سوالات متداول',
							},
						},
						{
							label: 'Migration Guide',
							link: '/migration/',
							translations: {
								fa: 'راهنمای مهاجرت',
							},
						},
					],
				},
				{
					label: 'Tutorials',
					translations: {
						fa: 'آموزش ها',
					},
					autogenerate: {
						directory: 'tutorials',
					},
				},
				{
					label: 'Tools',
					translations: {
						fa: 'ابزار',
					},
					items: [
						{
							label: 'IntelliJ Plugin',
							link: 'https://plugins.jetbrains.com/plugin/12129-bloc',
							translations: {
								fa: 'پلاگین IntelliJ',
							},
						},
						{
							label: 'VSCode Extension',
							link: 'https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc',
							translations: {
								fa: 'پلاگین VSCode',
							},
						},
					],
				},
				{
					label: 'Reference',
					translations: {
						fa: 'مرجع',
					},
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
	markdown: {
		rehypePlugins: [rehypeSlug, ...rehypeAutolink()],
	},
});
