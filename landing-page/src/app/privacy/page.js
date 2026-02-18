'use client'

import React from 'react'
import { ArrowLeft, Mail } from 'lucide-react'

export default function PrivacyPolicy() {
    return (
        <div className="min-h-screen bg-black text-white font-sans selection:bg-purple-500 selection:text-white p-6 md:p-12">
            <div className="max-w-4xl mx-auto">
                <a href="/" className="inline-flex items-center gap-2 text-slate-400 hover:text-white mb-8 transition-colors">
                    <ArrowLeft className="w-4 h-4" />
                    Back to Home
                </a>

                <h1 className="text-4xl md:text-5xl font-bold mb-8 bg-gradient-to-r from-purple-400 to-blue-500 bg-clip-text text-transparent">
                    Privacy Policy
                </h1>

                <div className="space-y-8 text-slate-300 leading-relaxed">
                    <section>
                        <h2 className="text-2xl font-bold text-white mb-4">1. Information Collection</h2>
                        <p>
                            Amozea is designed with privacy in mind. We do not collect any personal information from our users.
                            The app functions locally on your device and does not require you to create an account or sign in.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-white mb-4">2. Permissions</h2>
                        <p>
                            To function correctly, Amozea requires the following permissions:
                        </p>
                        <ul className="list-disc pl-5 mt-2 space-y-2">
                            <li><strong>Storage/Photos/Media:</strong> Required to save wallpapers to your device's gallery.</li>
                            <li><strong>Set Wallpaper:</strong> Required to apply wallpapers directly from the app.</li>
                            <li><strong>Internet:</strong> Required to download wallpapers from our servers.</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-white mb-4">3. Third-Party Services</h2>
                        <p>
                            We use Google AdMob to display advertisements within the app. AdMob may collect data to serve relevant ads.
                            You can learn more about how Google handles your data in their <a href="https://policies.google.com/privacy" className="text-purple-400 hover:underline">Privacy Policy</a>.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-white mb-4">4. Updates to This Policy</h2>
                        <p>
                            We may update this Privacy Policy from time to time. You are advised to review this page periodically for any changes.
                            These changes are effective immediately after they are posted on this page.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-bold text-white mb-4">5. Contact Us</h2>
                        <p>
                            If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at:
                            <br />
                            <a href="mailto:support@sarankar.com" className="flex items-center gap-2 mt-2 text-purple-400 hover:text-purple-300">
                                <Mail className="w-4 h-4" />
                                support@sarankar.com
                            </a>
                        </p>
                    </section>

                    <div className="pt-8 border-t border-white/10 text-sm text-slate-500">
                        Last updated: February 2026
                    </div>
                </div>
            </div>
        </div>
    )
}
