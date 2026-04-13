import React, { createContext, useContext, useMemo, useState } from 'react';
import { ar } from './translations/ar';
import { en, TranslationKey } from './translations/en';

type Locale = 'en' | 'ar';

type LocalizationContextType = {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: (key: TranslationKey) => string;
};

const LocalizationContext = createContext<LocalizationContextType | null>(null);

const translations = { en, ar };

export function LocalizationProvider({ children }: { children: React.ReactNode }): React.JSX.Element {
  const [locale, setLocale] = useState<Locale>('en');

  const value = useMemo(
    () => ({
      locale,
      setLocale,
      t: (key: TranslationKey) => translations[locale][key],
    }),
    [locale],
  );

  return <LocalizationContext.Provider value={value}>{children}</LocalizationContext.Provider>;
}

export function useLocalization(): LocalizationContextType {
  const context = useContext(LocalizationContext);
  if (!context) throw new Error('useLocalization must be used inside LocalizationProvider');
  return context;
}
