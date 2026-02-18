'use client'

import React from 'react'
import { ArrowLeft, Mail } from 'lucide-react'

export default function SupportPage() {
    return (
        <div className="min-h-screen bg-black text-white font-sans selection:bg-purple-500 selection:text-white p-6 md:p-12 flex flex-col items-center justify-center">
            <div className="max-w-2xl w-full text-center">
                <a href="/" className="inline-flex items-center gap-2 text-slate-400 hover:text-white mb-12 transition-colors self-start w-full">
                    <ArrowLeft className="w-4 h-4" />
                    Back to Home
                </a>

                <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-purple-400 to-blue-500 bg-clip-text text-transparent mb-6">
                    Amozea Support
                </h1>

                <p className="text-xl text-slate-300 mb-12 leading-relaxed">
                    Have questions about the app? Encountered a bug? We're here to help!
                    Please reach out directly via email, and our team will get back to you as soon as possible.
                </p>

                <div className="bg-white/5 border border-white/10 rounded-2xl p-8 backdrop-blur-sm hover:bg-white/10 transition-colors group">
                    <div className="w-16 h-16 bg-purple-600/20 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform">
                        <Mail className="w-8 h-8 text-purple-400" />
                    </div>

                    <h2 className="text-2xl font-bold mb-2">Email Us</h2>
                    <p className="text-slate-400 mb-6 text-sm">Typical response time: Within 24 hours</p>

                    <a
                        href="mailto:support@sarankar.com"
                        className="inline-flex items-center gap-2 bg-gradient-to-r from-purple-600 to-blue-600 px-8 py-3 rounded-full font-bold text-lg hover:shadow-[0_0_20px_rgba(147,51,234,0.3)] transition-all"
                    >
                        Send Email
                    </a>

                    <p className="mt-4 text-slate-500 text-sm font-mono">
                        support@sarankar.com
                    </p>
                </div>
            </div>
        </div>
    )
}
