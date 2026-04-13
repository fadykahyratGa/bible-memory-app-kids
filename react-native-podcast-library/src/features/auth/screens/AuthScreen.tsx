import React, { useState } from 'react';
import { Alert, Linking, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { makeRedirectUri } from 'expo-auth-session';
import { supabase } from '../../../lib/supabase';
import { useLocalization } from '../../../localization/LocalizationProvider';

export function AuthScreen(): React.JSX.Element {
  const { t } = useLocalization();
  const [isRegister, setIsRegister] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const ensureProfile = async (): Promise<void> => {
    const { data } = await supabase.auth.getUser();
    if (!data.user) return;

    await supabase.from('profiles').upsert({ id: data.user.id });
  };

  const submit = async (): Promise<void> => {
    const cleanEmail = email.trim();
    if (!cleanEmail || password.length < 6) {
      Alert.alert('Validation', t('validationError'));
      return;
    }

    setLoading(true);
    try {
      if (isRegister) {
        const { error } = await supabase.auth.signUp({ email: cleanEmail, password });
        if (error) throw error;
        await ensureProfile();
        Alert.alert('Success', t('successRegister'));
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email: cleanEmail, password });
        if (error) throw error;
        await ensureProfile();
      }
    } catch (error: any) {
      Alert.alert(t('authenticationError'), error.message ?? 'Unable to authenticate');
    } finally {
      setLoading(false);
    }
  };

  const loginWithGoogle = async (): Promise<void> => {
    try {
      const redirectTo = makeRedirectUri();
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: { redirectTo, skipBrowserRedirect: true },
      });

      if (error) throw error;
      if (data?.url) {
        await Linking.openURL(data.url);
      }
    } catch (error: any) {
      Alert.alert(t('authenticationError'), error.message ?? 'Google login failed');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{t('appTitle')}</Text>
      <Text style={styles.subtitle}>{isRegister ? t('createAccount') : t('login')}</Text>

      <TextInput
        style={styles.input}
        autoCapitalize="none"
        keyboardType="email-address"
        placeholder={t('email')}
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        secureTextEntry
        placeholder={t('password')}
        value={password}
        onChangeText={setPassword}
      />

      <Pressable style={styles.primary} onPress={submit} disabled={loading}>
        <Text style={styles.primaryText}>{loading ? '...' : isRegister ? t('register') : t('login')}</Text>
      </Pressable>

      <Pressable style={styles.googleButton} onPress={loginWithGoogle}>
        <Text style={styles.googleText}>{t('googleLogin')}</Text>
      </Pressable>

      <Pressable onPress={() => setIsRegister((prev) => !prev)}>
        <Text style={styles.link}>{isRegister ? t('haveAccount') : t('dontHaveAccount')}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, justifyContent: 'center', backgroundColor: '#fff' },
  title: { fontSize: 24, fontWeight: '800', marginBottom: 8, textAlign: 'center' },
  subtitle: { color: '#6b7280', marginBottom: 16, textAlign: 'center' },
  input: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginBottom: 10,
  },
  primary: {
    backgroundColor: '#2563eb',
    borderRadius: 10,
    alignItems: 'center',
    paddingVertical: 11,
    marginBottom: 10,
  },
  primaryText: { color: '#fff', fontWeight: '700' },
  googleButton: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 10,
    alignItems: 'center',
    paddingVertical: 11,
    marginBottom: 12,
  },
  googleText: { color: '#111827', fontWeight: '700' },
  link: { textAlign: 'center', color: '#2563eb', fontWeight: '600' },
});
