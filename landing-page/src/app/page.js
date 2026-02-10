'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { Sparkles, Zap, Smartphone, Palette, Layers, Download, ChevronRight } from 'lucide-react'

export default function AmozeaLanding() {
    return (
        <div className="min-h-screen bg-black text-white font-sans selection:bg-purple-500 selection:text-white">
            {/* Navbar */}
            <nav className="fixed top-0 w-full z-50 backdrop-blur-xl bg-black/50 border-b border-white/5">
                <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center">
                            <Sparkles className="w-5 h-5 text-white" />
                        </div>
                        <span className="text-xl font-bold tracking-tight">Amozea</span>
                    </div>
                    <div className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-400">
                        <a href="#features" className="hover:text-white transition-colors">Features</a>
                        <a href="https://sarankar.com" className="hover:text-white transition-colors">Developer</a>
                    </div>
                    <a
                        href="https://play.google.com/store/apps/details?id=com.amozea.wallpapers"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="bg-white text-black px-5 py-2 rounded-full font-bold text-sm hover:bg-slate-200 transition-colors shadow-[0_0_20px_rgba(255,255,255,0.1)]"
                    >
                        Download
                    </a>
                </div>
            </nav>

            {/* Hero Section */}
            <header className="pt-32 pb-20 px-6 relative overflow-hidden">
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[600px] bg-purple-600/10 blur-[150px] rounded-full pointer-events-none" />

                <div className="max-w-4xl mx-auto text-center relative z-10">
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8, ease: "easeOut" }}
                    >
                        <span className="inline-block py-1 px-4 rounded-full bg-white/5 border border-white/10 text-purple-400 text-xs font-bold tracking-[0.2em] mb-8">
                            PREMIUM AMOLED WALLPAPERS
                        </span>
                        <h1 className="text-6xl md:text-8xl font-black tracking-tighter mb-8 leading-[0.9]">
                            Deep Black. <br />
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-purple-400 via-pink-500 to-blue-500">Pure Vibrant.</span>
                        </h1>
                        <p className="text-xl text-slate-400 mb-12 max-w-2xl mx-auto leading-relaxed font-light">
                            Elevate your display with carefully curated 4K AMOLED wallpapers. Optimized for battery life and designed for visual excellence.
                        </p>

                        <div className="flex flex-col sm:flex-row items-center justify-center gap-6">
                            <a
                                href="https://play.google.com/store/apps/details?id=com.amozea.wallpapers"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="flex items-center gap-3 bg-white text-black px-10 py-5 rounded-2xl font-black text-lg transition-all hover:scale-105 shadow-2xl shadow-white/5"
                            >
                                <Download className="w-6 h-6" />
                                Download for Android
                            </a>
                            <a
                                href="#features"
                                className="flex items-center gap-2 bg-white/5 hover:bg-white/10 text-white px-10 py-5 rounded-2xl font-bold text-lg transition-colors border border-white/10"
                            >
                                Features
                                <ChevronRight className="w-5 h-5" />
                            </a>
                        </div>
                    </motion.div>
                </div>
            </header>

            {/* Feature Cards */}
            <section id="features" className="py-24 border-y border-white/5 bg-slate-950/20">
                <div className="max-w-6xl mx-auto px-6">
                    <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4">
                        {[
                            {
                                icon: <Zap className="w-6 h-6 text-yellow-400" />,
                                title: "Battery Saving",
                                desc: "True black pixels stay off, extending your OLED battery life."
                            },
                            {
                                icon: <Smartphone className="w-6 h-6 text-blue-400" />,
                                title: "Auto Change",
                                desc: "Set your favorites and let Amozea refresh your look daily."
                            },
                            {
                                icon: <Palette className="w-6 h-6 text-pink-400" />,
                                title: "Dual Support",
                                desc: "Apply home and lock screen separately with one tap."
                            },
                            {
                                icon: <Layers className="w-6 h-6 text-purple-400" />,
                                title: "4K Resolution",
                                desc: "Ultra-high definition imagery curated by professional artists."
                            }
                        ].map((feature, i) => (
                            <div key={i} className="group p-8 rounded-[2rem] bg-white/[0.02] border border-white/5 hover:bg-white/[0.05] transition-all duration-500">
                                <div className="w-12 h-12 bg-white/5 rounded-2xl flex items-center justify-center mb-8 group-hover:scale-110 transition-transform">
                                    {feature.icon}
                                </div>
                                <h3 className="text-xl font-bold mb-3">{feature.title}</h3>
                                <p className="text-slate-500 leading-relaxed text-sm font-medium">{feature.desc}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer className="py-16 bg-black">
                <div className="max-w-6xl mx-auto px-6 flex flex-col items-center">
                    <div className="flex items-center gap-2 mb-8">
                        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center">
                            <Sparkles className="w-6 h-6 text-white" />
                        </div>
                        <span className="text-2xl font-bold">Amozea</span>
                    </div>
                    <div className="flex gap-8 mb-10 text-slate-500 text-sm font-medium">
                        <a href="https://sarankar.com" className="hover:text-white transition-colors">Developer Website</a>
                        <a href="mailto:support@sarankar.com" className="hover:text-white transition-colors">Support</a>
                    </div>
                    <p className="text-slate-700 text-xs tracking-widest uppercase font-bold">
                        &copy; 2026 Sarankar Developers. All rights reserved.
                    </p>
                </div>
            </footer>
        </div>
    )
}
