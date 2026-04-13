import React, { useState } from 'react';
import { Alert, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { supabase } from '../lib/supabase';

export function AuthScreen(): React.JSX.Element {
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
      Alert.alert('Validation', 'Enter a valid email and password (minimum 6 chars).');
      return;
    }

    setLoading(true);
    try {
      if (isRegister) {
        const { error } = await supabase.auth.signUp({ email: cleanEmail, password });
        if (error) throw error;
        await ensureProfile();
        Alert.alert('Success', 'Registration complete. Please check your email if confirmation is enabled.');
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email: cleanEmail, password });
        if (error) throw error;
        await ensureProfile();
      }
    } catch (error: any) {
      Alert.alert('Authentication error', error.message ?? 'Unable to authenticate');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Christian Podcast Library</Text>
      <Text style={styles.subtitle}>{isRegister ? 'Create account' : 'Login'}</Text>

      <TextInput
        style={styles.input}
        autoCapitalize="none"
        keyboardType="email-address"
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        secureTextEntry
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
      />

      <Pressable style={styles.primary} onPress={submit} disabled={loading}>
        <Text style={styles.primaryText}>{loading ? 'Please wait...' : isRegister ? 'Register' : 'Login'}</Text>
      </Pressable>

      <Pressable onPress={() => setIsRegister((prev) => !prev)}>
        <Text style={styles.link}>
          {isRegister ? 'Already have an account? Login' : "Don't have an account? Register"}
        </Text>
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
    marginBottom: 12,
  },
  primaryText: { color: '#fff', fontWeight: '700' },
  link: { textAlign: 'center', color: '#2563eb', fontWeight: '600' },
});
